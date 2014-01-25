# encoding: utf-8

require_relative "../constants"
require_relative '../utils/logging'

# @author Alexei Matyushkin
module Qipowl
  
  # Operates +mapping+ for loaded +YAML+ rules files.
  #
  # - For top level sections, each section name
  #   should have the corresponding method within Mapping class;
  #   default is `[:includes]` which is processed with {#includes}
  #   method which is simply loads rules from the respective file
  #
  # Mapping may be loaded from YAML file, as well as be merged
  # against other YAML file, hash or `Ruler` instance.  
  module Ruler
    include TypoLogging
    extend self

    @@bowlers = {} # FIXME REDIS!!!!
    
    def get_bowler id: nil, type: nil
      @@bowlers[id] || new_bowler(type, true)
    end
  
    def new_bowler type, persistent: false, additional_maps: []
      yaml, clazz = \
        case type
        when Class
          ["#{type.to_s.split('::').last.downcase}", type]
        when String, Symbol
          ["#{type.to_s.downcase}", Qipowl::Bowlers.const_get(type.to_s.capitalize.to_sym)]
        end
      
      raise NameError.new("Invalid bowler type: #{type}") \
        unless clazz.is_a?(Class) && clazz < Qipowl::Bowlers::Bowler
      
      id = "#{Time.now.to_i}#{rand(1..1_000_000_000)}"
      name = "#{clazz.name.split('::').last}_#{id}"
      clazz = Qipowl::Bowlers.const_set(name, Class.new(clazz))

      teach_class clazz, get_yaml(yaml, additional_maps: additional_maps)

      persistent ? [@@bowlers[id] = clazz.new, id] : clazz.new
    end
      
  private
    def get_yaml yaml, additional_maps: []
      clazz = Qipowl::Mappers.const_get("#{yaml.capitalize}BowlerMapper")
      raise NameError.new("Invalid mapper type: #{clazz}") \
        unless clazz.is_a?(Class) && clazz < Qipowl::Mappers::BowlerMapper
        
      result = clazz.new
      [*additional_maps].each { |map|
        result.merge! map
      }
      result
    end

    def teach_class_prepare clazz
      clazz.const_set('CUSTOM_TAGS', {}) unless clazz.const_defined? 'CUSTOM_TAGS'
      clazz.const_set('ENCLOSURES_TAGS', {}) unless clazz.const_defined? 'ENCLOSURES_TAGS'
      Qipowl::ENTITIES.each { |section|
        clazz.const_set("#{section.upcase}_TAGS", {}) \
          unless clazz.const_defined? "#{section.upcase}_TAGS"
      }
      clazz.const_set('ENTITIES', {}) unless clazz.const_defined? 'ENTITIES'
      clazz.const_set('TAGS', {}) unless clazz.const_defined? 'TAGS'
    end

    def ∃_template section
      %Q{
        def ∃_#{section} entity
          self.class::#{section.upcase}_TAGS.each { |k, v|
            next unless k == entity
            v = {:tag => v} unless Hash === v
            v[:origin] = self.class::TAGS[v[:tag]]
            v[:section] = k
            return v
          }
          nil
        end
      }
    end

    def teach_class clazz, mapper
      teach_class_prepare clazz

      clazz::CUSTOM_TAGS.rmerge! mapper.to_hash[:custom] if mapper.to_hash[:custom]
      clazz::ENCLOSURES_TAGS.rmerge! mapper.to_hash[:enclosures] if mapper.to_hash[:enclosures]
      clazz::ENTITIES.rmerge! mapper.entities if mapper.entities

      clazz.class_eval ∃_template 'enclosures'

      Qipowl::ENTITIES.each { |section|
        next unless mapper.entities && mapper.entities[section.to_sym]
        clazz.const_get("#{section.upcase}_TAGS").rmerge! mapper.entities[section.to_sym]
        clazz.const_get('TAGS').rmerge! clazz.const_get("#{section.upcase}_TAGS")
        clazz.class_eval ∃_template section

        mapper.entities[section.to_sym].each { |key, value|
          tag = Hash === value && value[:marker] ? value[:marker] : "∀_#{section}"
          clazz.class_eval %Q{
            alias_method :#{key}, :#{tag}
          } unless clazz.instance_methods.include?(key.to_sym)
        }
      }
    end
  end
end
