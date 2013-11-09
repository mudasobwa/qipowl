# encoding: utf-8

require 'yaml'

require_relative '../utils/hash_recursive_merge'
require_relative '../utils/logging'

module Typogrowl
  class Mapping
    include TypoLogging
    
    attr_reader :hash

    SUGAR  = %i(synsugar)
    SPICES = %i(flush block magnet inplace linewide)
    PEPPER = %i(custom)
    SALT   = %i(enclosures)

    (SUGAR + SPICES + SALT).each { |section|
      define_method(section) { self[section] }
    }
    
    def initialize clazz, yaml 
      @clazz  = clazz
      @hash   = {}
      merge! yaml
    end

    def get section, key
      key.nil? ? nil : @hash[section][key.to_sym] || @hash[section][key.to_s.unbowl.to_sym]
    end

    def dup_key original, dupped
      section = section_for original
      @hash[section][dupped] = @hash[section][original] if @hash[section]
      enclosures[dupped] = enclosures[original] if enclosures[original]
    end
      
    def [] section
      raise "Invalid section #{section}" unless (SUGAR + SPICES + PEPPER + SALT).include?(section)
      @hash[section]
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
    def merge! other
      @hash.rmerge!(
        case other
        when Hash then other
        when String then YAML.load_file(other)
        when Mapping then other.hash
        else logger.warn "Tried to merge unmergeable (#{other})"
        end
      )
    ensure
      extend_class @clazz
    end

  private    
    # Fixes mapping after initialization and merging rules by dynamically
    # appending aliases and custom methods to class for rules.
    #
    # @param [Class] clazz the class to extend with this mapping
    def extend_class clazz
      SPICES.each { |spice|
        spice_method = @hash[spice].first.first
        @hash[spice].each { |tag, htmltag|
          clazz.class_eval %Q{
            alias :#{tag.to_s.bowl} :#{spice_method}
          } unless clazz.instance_methods(false).include?(tag)
        }
      }
      PEPPER.each { |pep|
        @hash[pep].each { |tag, re|
          clazz.class_eval %Q{
            def #{tag.to_s.bowl} *args
              ["#{re.to_s.bowl}", args]
            end
          } unless clazz.instance_methods(false).include?(tag)
        }
      }
    end

    def section_for tag
      result = SPICES.each { |spice|
        break spice if @hash[spice].keys.include?(tag)
      }
      result.to_sym rescue nil
    end

  end
end
