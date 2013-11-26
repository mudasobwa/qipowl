# encoding: utf-8

require 'yaml'

require_relative '../utils/hash_recursive_merge'
require_relative '../utils/logging'

# @author Alexei Matyushkin
module Qipowl
  
  # Operates +mapping+ for loaded +YAML+ rules files.
  #
  # Sections within rules files are described by constants:
  #
  # - {Mapping.RECIPE} those are special sections, each section name
  #   should have the corresponding method within Mapping class;
  #   default is `[:includes]` which is processed with {#includes}
  #   method which is simply loads rules from the respective file
  # - {Mapping.SUGAR} sections are supported with direct accessor
  # - {Mapping.SPICES} main dish has five default sections
  #   `:flush`, `:block`, `:magnet`, `:inplace`, `:linewide`; each
  #   of them is operated in different manner in {Bowler}s. Spices
  #   are provided with an ability of adding/removing items
  # - {Mapping.PEPPER} children deal with both left and right side
  #   operands (corresponding methods have two parameters and
  #   bowler must perform some preprocessing to make a function-like
  #   entity from the `A op B`)
  # - {Mapping.SALT} members operate as “supervisors” of “spices”,
  #   currently we support `:enclosures` for enclosing HTML tags
  #
  # Mapping may be loaded from YAML file, merged agains other YAML file.
  # hash or Mapping.
  class Mapping
    include TypoLogging
    
    attr_reader :hash

    RECIPE = %i(includes)
    SUGAR  = %i(synsugar)
    PEPPER = %i(handshake)
    SPICES = %i(flush block magnet inplace linewide)
    SALT   = %i(enclosures)

    (SUGAR + PEPPER + SPICES + SALT).each { |section|
      define_method section, ->(key, precisely = false) {
        precisely or key.nil? ?
          @hash[section][key] :
          @hash[section][key.unbowl] || @hash[section][key.unbowl.wstrip]
      }
    }
    
    # Default initializer.
    #
    # @param clazz an eigenclass this mapping will be operated with
    # @param [String|Hash|Mapping] yaml YAML file, hash or other Mapping instance
    def initialize clazz, yaml 
      @clazz  = clazz
      @hash   = {}
      merge! yaml
    end

    # Quick accessor for sections.
    #
    # @param [Symbol] section the section to retrieve
    # @return [Hash] the subhash of main YAML for the given section
    def [] section
      raise "Invalid section #{section}" unless (SUGAR + SPICES + PEPPER + SALT).include?(section)
      @hash[section]
    end
    
    def params key
      [*@hash[:params][key]]
    end

    # Returns value for the key from section.
    #
    # @param [Symbol] section the section to retrieve value for key from
    # @param [Symbol] key the key to retrieve value for
    # @return [String|Symbol] the value for the key from the section given
    #def get section, key
    #  key.nil? ? nil : @hash[section][key] || @hash[section][key.unbowl]
    #end

    # Duplicates key from {Mapping.SPICES} and the corresponding {Mapping.SALT} with other name.
    #
    # @param [Symbol] original the key to dup
    # @param [Symbol] dupped the name for the newly created dupped key
    def dup_spice original, dupped
      section = SPICES.each { |spice| break spice if @hash[spice].keys.include?(original) }
      if @hash[section]
        @hash[section][dupped] = @hash[section][original] 
        @hash[:enclosures][dupped] = @hash[:enclosures][original] if @hash[:enclosures][original]
        @clazz.class_eval %Q{
          alias_method :#{dupped.bowl}, :#{original}
        } unless @clazz.instance_methods(true).include?(dupped.bowl)
      end
      return @hash[section]
    end
    
    # Adds new +entity+ in the section specified.
    # E. g., call to
    #
    #     add_spice :linewide, :°, :deg, :degrees
    #
    # in HTML implementation adds a support for specifying something like:
    #
    #     ° 15
    #     ° 30
    #     ° 45
    #
    # which is to be converted to the following:
    #
    #     <degrees>
    #       <deg>15</deg>
    #       <deg>30</deg>
    #       <deg>45</deg>
    #     </degrees>
    #
    # @param [Symbol] section the section (it must be one of {Mapping.SPICES}) to add new key to
    # @param [Symbol] key the name for the key
    # @param [Symbol] value the value
    # @param [Symbol] enclosure_value optional value to be added for the key into enclosures section
    def add_spice section, key, value, enclosure_value = null
      if SPICES.include?(section)
        @hash[section][key] = value
        @hash[:enclosures][key] = enclosure_value if enclosure_value
        @clazz.class_eval %Q{
          alias_method :#{key.bowl}, :#{@hash[section].first.first}
        } unless @clazz.instance_methods(true).include?(key.bowl)
      else
        logger.warn "Trying to add key “#{key}” in an invalid section “#{section}”. Ignoring…"
      end
    end

    # Removes key from both {Mapping.SPICES} and {Mapping.SALT}. See {#add_spice}
    #
    # @param [Symbol] key the key to be removed
    def remove_spice key
      section = SPICES.each { |spice| break spice if @hash[spice].keys.include?(key) }
      result = {}
      if @hash[section]
        result[:section] = section
        result[:value] = @hash[section].delete(key)
        result[:enclosure] = @hash[:enclosures].delete(key)
        @clazz.class_eval %Q{
          remove_method :#{key.bowl}
        } if @clazz.instance_methods(true).include?(key.bowl)
      else
        logger.warn "Trying to remove inexisting key “#{key}” (sections: “#{section}”). Ignoring…"
      end
      result
    end

    # Helper method to add custom DSL description to processing.
    #
    # In case one wants `☢` symbol to be treated as markup for warnings,
    # the only thing needed is to add the respective line to YAML rules.
    # Since “warning” behaves exactly as the paragraph, but has the “special
    # class” in terms of HTML, all we need is to do:
    #
    #     tg = Qipowl::Html.new
    #     tg.mapping.merge! { :linewide => { :☢ => :p†warning }}
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
    # @param [Hash|String] other if string is given as the parameter, it’s treated as the name of YAML rules file. `Hash` is being merged explicitly.
    # @return [Hash] the result of merging new rules against the standard set.
    def merge! other
      @hash.rmerge!(
          case other
          when Hash then other
          when String then hash_from_yaml(other)
          when Mapping then other.hash
          else logger.warn "Tried to merge unmergeable (#{other})"
          end
      )

      RECIPE.each { |recipe|
        next unless recipes = @hash.delete(recipe)
        self.method(recipe).call(recipes) rescue \
          logger.warn("Wrong recipe section: #{recipe}. Try to implement respective method in Mapping class")
      }
    ensure
      extend_class @clazz
    end

  private
    # Helper for `includes` section of {Mapping.RECIPE}s. Symply loads and merges files.
    # 
    # @param [Array] files an array of files to merge into
    def includes files
      [*files].each { |f|
        merge! f
      }
    end
  
    # Fixes mapping after initialization and merging rules by dynamically
    # appending aliases and custom methods to class for rules.
    #
    # @param [Class] clazz the class to extend with this mapping
    def extend_class clazz
      (SPICES + PEPPER).each { |spice|
        next unless @hash[spice] && !@hash[spice].empty?
        spice_method = @hash[spice].first.first
#        logger.debug "Deriving default #{spice} method" unless \
#          clazz.instance_methods(false).include?(spice_method)
        @hash[spice].each { |tag, htmltag|
          clazz.class_eval %Q{
            alias_method :#{tag.bowl}, :#{spice_method}
          } unless clazz.instance_methods(true).include?(tag.bowl)
        }
      }
    end

    # Loads hash from the YAML file given, trying current, `tagmaps` and
    # `lib/tagmaps` as default directories to load from. To load file
    # from somewhere else use full path.
    #
    # @param [String] file the file to load YAML from
    # @return [Hash|Nil] the result if it was loaded successfully, nil otherwise
    def hash_from_yaml file
      hash = ['', "#{Dir.pwd}/", 'tagmaps/', 'lib/tagmaps/'].each { |dir|
        result = YAML.load_file("#{dir}#{file}") rescue nil
        break result if result
      }
    end
  end
end
