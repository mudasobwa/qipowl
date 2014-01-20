# encoding: utf-8

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
    @@yamls = {}

    
    def get_bowler id: nil, type: nil
      @@bowlers[id] || new_bowler(type, true)
    end
  
    def new_bowler type, persistent = false
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

      teach_class clazz, get_yaml(yaml)

      persistent ? [@@bowlers[id] = clazz.new, id] : clazz.new
    end
      
  private
    def get_yaml yaml
      return @@yamls[yaml] if @@yamls[yaml]
      
      clazz = Qipowl::Mappers.const_get("#{yaml.capitalize}BowlerMapper")
      raise NameError.new("Invalid mapper type: #{clazz}") \
        unless clazz.is_a?(Class) && clazz < Qipowl::Mappers::BowlerMapper
        
      @@yamls[yaml] = clazz.new
    end
        
    # FIXME Make contants PER-EIGENCLASS
    def teach_class clazz, mapper
      clazz.const_set("CUSTOM_TAGS", mapper.to_hash[:custom])
      clazz.const_set("ENCLOSURES_TAGS", mapper.to_hash[:enclosures])
      clazz.const_set("ENTITIES", mapper.entities)
      clazz.const_set("TAGS", {})
      clazz.class_eval %Q{
        def ∃_enclosures entity
          self.class::ENCLOSURES_TAGS.each { |k, v|
            next unless k == entity
            v = {:tag => v} unless Hash === v
            v[:origin] = self.class::TAGS[v[:tag]]
            return v
          }
          nil
        end
      }
      %w(block alone magnet grip regular).each { |section|
        clazz.const_set("#{section.upcase}_TAGS", mapper.entities[section.to_sym])
        clazz.class_eval %Q{
          self::TAGS.rmerge! self::#{section.upcase}_TAGS
          def ∃_#{section} entity
            self.class::#{section.upcase}_TAGS.each { |k, v|
              next unless k == entity
              v = {:tag => v} unless Hash === v
              v[:section] = k
              return v
            }
            nil
          end
          def ∃_#{section}_tag entity
                ∃_#{section}(entity)[:tag] if ∃_#{section}(entity)
          end
        }
        mapper.entities[section.to_sym].each { |key, value|
          tag = Hash === value && value[:marker] ? value[:marker] : "∀_#{section}"
          clazz.class_eval %Q{
            alias_method :#{key}, :#{tag}
          } unless clazz.instance_methods.include?(key)
        }
      }
      clazz.class_eval %Q{
        def ∀_tags
          self.class::TAGS.keys
        end
      }
    end
  end
end
