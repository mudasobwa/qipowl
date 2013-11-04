# encoding: utf-8

require 'yaml'
require 'uri'

require_relative 'monkeypatches'
require_relative '../utils/logging'

# @author Alexei Matyushkin
module Typogrowl

  # Base class for all the parsers.
  #
  # Technically it may be instantiated, but that’s meaningless.
  # Main operation method for it and all the descendants is
  # {#parse_and_roll}. It sequentially executes following
  # private methods:
  #
  # - {#defreeze}
  # - {#roast}
  # - {#serveup}
  #
  # Normally the developer does not need to interfere the {#roast}
  # method which proceeds the input string. To prepare the input
  # for +evaluation+ one overwrites {#defreeze}, for some afterwork
  # the {#serveup} method is here.
  #
  # Descendants are supposed to overwrite {#method_missing} for some
  # custom processing and introduce DSL methods, which will be executed
  # by `eval` inside the {#roast} method.
  #
  # Instance variables `:in` and `:out` are here to gain an access to
  # the last interpreted input string and the result of evaluation
  # respectively.
  #
  class Bowler
    include TypoLogging
    
    # The last interpreted input string and it′s result of evaluation
    # respectively.
    attr_reader :in, :out, :mapping

    # Internal constant for joining/splitting the strings during processing.
    # Override on your own risk. I can′t imagine why you would need to do so.
    SEPARATOR = $, || ' '

    # Main execution method.
    #
    # @param [String] str the string to be processed
    # @return [String] the result of string evaluation
    def parse_and_roll str
      @callee = nil
      serveup roast defreeze @in = str
    end

    # Helper method to add custom DSL description to processing.
    #
    # In case one wants `☢` symbol to be treated as markup for warnings,
    # the only thing needed is to add the respective line to YAML rules.
    # Since “warning” behaves exactly as the paragraph, but has the “special
    # class” in terms of HTML, all we need is to do:
    #
    #     tg = Typogrowl::Html.new
    #     tg.merge_rules { :linewide => { :☢ => :p†warning }}
    #
    # In case the processing is more complicated, one might need to
    # implement the respective method in `Bowler` descendant:
    #
    #     def ☢ *args
    #       args.map { |arg| arg.upcase }
    #     end
    #
    # In the latter example all the words beyond `☢` will be uppercased.
    #
    # @param [Hash|String] file_or_hash if string is given as the parameter, it’s treated as the name of YAML rules file. `Hash` is being merged explicitly.
    #
    # @return [Hash] the result of merging new rules against the standard set.
    #
    def merge_rules file_or_hash
      rules = case file_or_hash
              when Hash then file_or_hash
              when String then YAML.load_file(file_or_hash)
              end
      @mapping.rmerge!(rules) if rules
      fix_mapping if respond_to?(:fix_mapping)
#    rescue
#      logger.error "Inconsistent call to `merge_rules`. Param: #{file_or_hash}."
    end

    # Everything is a DSL, remember?
    #
    # @return true
    def respond_to?(method)
      true
    end

    # Everything is a DSL, remember? Even constants.
    # @todo This fails to do with DSLing words, beginning with capitals :-(
    #
    # @return the constant name as is
    def self.const_missing name
      name
    end

    # If somebody needs to interfere the standard processing,
    # she supposed to introduce `special_handler` method. The descendants
    # will be processed before standard operation (which in fact simply
    # collects words within an array one by one.)
    def method_missing method, *args, &block
      method, *args = special_handler(method, *args, &block) \
        if self.private_methods.include?(:special_handler)
      [method, args].flatten
    end

    # @param [String] file name of file to read rules from, defaults to the class name of the caller class.
    def initialize file = nil
      @mapping = {}
      fname = "#{File.dirname(__FILE__)}/../../tagmaps/#{self.class.name.downcase.split('::').last}.yaml"
      file = fname if !file && File.exist?(fname)
      
      merge_rules file
    end

  private
    # The handler of the last “orphaned” text block in the input string.
    #
    # E.g.:
    #     Here goes a quite significant list:
    #
    #     • line item 1
    #      • nested li1
    #      • nested li 2
    #     • line item 2
    #
    # While all line items are operated by `•` method, the top sentence
    # is orphaned (has no prepnding DSL method to be called on.)
    # Since we still need to handle it somehow, the {#orphan} method is here.
    #
    # @param [String] str the string to be operated “bu default rule”
    #
    # @return [String] the processed input (in derivatives, here it returns the untouched input string itself)
    def orphan str
      str
    end

    # The handler for harvesting partial result.
    #
    # Processing sometimes calls this method, designating the meaningful
    # part of input text is done and should be yielded. E.g. when the
    # block of code is processed:
    #
    #     Λ ruby
    #       @mapping[:inplace].each { |tag, htmltag|
    #         do_smth tag, htmltag
    #       }
    #     Λ
    #
    # After we have this part of input processed, it should be considered
    # “done.” So block processors call {#harvest} to store processed parts.
    #
    # @param [Symbol] callee of this method. Typogrowl hardly relies on method namings and sometimes we may need to know if the call was made by, say, lineitem DSL (`•`), not datalist (`▷`).
    # @param [String] str string to yield
    #
    # @return nil
    def harvest callee, str
      @yielded << str
      nil
    end

    # Preprocessor of input string. The best candidate to override in
    # descendants in case of input should be slightly “normalized”.
    # By default it {String#bowl}es the input, substituting:
    #
    # - symbols like dots, commas and parenthesis to Burmese letters
    # (I was unable to locate Klingon in UTF tables, pity on me);
    # - digits staying alone are prepended with another weird UTF symbol,
    # making it well-formed ruby methods;
    # - ruby method omonims, available in this context, are prepended with
    # same UTF symbol, and therefore are made distinguishable from
    # methods themselves. Now it’s safe to have input string, containing,
    # say, `I like eval` text inside.
    #
    # Html parser, for instances, utilizes this method to provide support
    # for human-readable link representation:
    #
    #     — Wikipedia, http://wikipedia.org
    #
    # which is hardly DSL-able as is. {#defreeze} there parses the input
    # and substitutes those links with “well-formed”:
    #
    #     ⚓http://wikipedia.org Wikipedia⚓
    #
    # @todo Make this configurable
    #
    # @param [String] str string to prepare for {#roast}
    #
    # @return [String] preprocessed string
    def defreeze str
#      raise Exception.new "Reserved symbols are used in input. Aborting…" \
#        if /[#{String::BOWL_SYMBOLS}]/ =~ str
      out = str.dup
      @mapping[:synsugar].each { |re, subst|
        out.gsub!(/#{re}/, subst)
      } if @mapping[:synsugar]
      out.bowl
    end

    # …Drum-roll… Main handler.
    #
    # It splits the input into array of “paragraphs” (by empty lines,
    # `/\R{2}/` in terms of Ruby regexps.) Then it applies syntactic sugar
    # substitutes from rules file. After all it `eval`s input content.
    #
    # Yes, the backbone call in this method is call to `eval (input)`.
    #
    # @param [String] str the input string. NB! It might be dangerous to call this method without preceeding call to {#defreeze} (mainly {String#bowl} on input inside {#defreeze}).
    #
    # @return [String] roasted input. It still requires to be {String#unbowl}ed.
    def roast str
      @yielded = []
      # FIXME Understand, why reverse here    ⇓⇓⇓⇓⇓⇓⇓ is needed and (!) works
      courses = str.split(/\R{2,}/).reverse
      courses.each {|dish|
        rest = eval(dish.carriage)
        harvest(nil, orphan([*rest].join(SEPARATOR))) if rest
      } unless courses.nil?
      @yielded.reverse.join("\n")
    end

    # Post-processing of roasted input. By default it simply {String#unbowl}s
    # the result and returns it. It there were some addition handling made
    # in {#defreeze} it’s the right place to revert it back.
    #
    # @param [String] str roasted output.
    #
    # @return [String] the result of processing.
    def serveup str
      @out = str.uncarriage.unbowl
    end

    # Lookups the section in YAML rules file for the given tag.
    #
    # @param [Symbol] tag to lookup section for
    # @return [Symbol] section found or nil if there were no such section.
    # @private
    def section tag
      result = @mapping.each { |k, v|
        break k if Hash === v && v.keys.include?(tag)
      }
      return Symbol === result ? result : nil
    end
  end
end
