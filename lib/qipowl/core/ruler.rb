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
  class Ruler
    include TypoLogging

    @@bowlers = {} # FIXME REDIS!!!!
    @@yamls = {}
    
    private_class_method :new
    
    class << self
      def get_bowler id: nil, type: nil
        @@bowlers[id] || new_bowler(type, true)
      end
    
      def new_bowler type, persistent = false
        yaml, clazz = \
          case type
          when Class
            ["#{type.to_s.split('::').last.downcase}", type]
          when String, Symbol
            ["#{type.downcase}", Qipowl::Bowlers.const_get(type.to_s.capitalize.to_sym)]
          end
        
        raise NameError.new("Invalid bowler type: #{type}") \
          unless clazz.is_a?(Class) && clazz < Qipowl::Core::Bowler
        
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
      def teach_class clazz, yaml
        # FIXME 
      end
    end
  end
end
