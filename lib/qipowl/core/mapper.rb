# encoding: utf-8

require 'yaml'

require_relative '../core/monkeypatches'
require_relative '../utils/hash_recursive_merge'
require_relative '../utils/logging'

# @author Alexei Matyushkin
module Qipowl::Mappers
  
  # Operates +mapping+ for loaded +YAML+ rules files.
  #
  # - For top level sections, each section name
  #   should have the corresponding method within Mapping class;
  #   default is `[:includes]` which is processed with {#includes}
  #   method which is simply loads rules from the respective file
  #
  # Mapping may be loaded from YAML file, as well as be merged
  # against other YAML file, hash or `Ruler` instance.
  class Mapper
    def initialize input = nil
      @hash = {}
      merge!(input) unless input.nil?
    end
    def to_hash
      @hash
    end
    def merge! input
      input = load_yaml(input) if input.is_one_of?(String, IO)
      raise ArgumentError.new "Invalid map for merge in Mapper" \
        unless input.respond_to? :to_hash        

      input.delete(:includes).each { |inc|
        merge! inc
      } rescue NoMethodError

      @entities_dirty = true
      @hash.rmerge!(input.to_hash)
    end
  private
  # FIXME Make file search more flexible!!!
    def load_yaml input
      IO === input ?
        YAML.load_stream(input) :
        YAML.load_file("#{Qipowl.bowlers_dir}/#{input.downcase}.yaml")
    end
  end
  
  class BowlerMapper < Mapper
    def initialize input = nil
      input = self.class.name.split('::').last.downcase.gsub(/bowlermapper\Z/, '') if input.nil?
      super input
    end
    @entities = nil
    @entities_dirty = true

    def entities
      return @entities unless @entities_dirty
      @entities = {}
      @hash[:entities].each { |key, value| # :block. :alone etc
        @entities[key] ||= {}
        value.each { |k, v|
          # Append keys
          @entities[key][k.bowl] = v.dup
          if Hash === v
            @entities[key][k.bowl].delete(:synonyms) 
            # Append explicit synonyms
            v[:synonyms].each { |syn|
              (@entities[key][syn.bowl] = v.dup).delete(:synonyms)
            } if v[:synonyms]
          end
        }
      }
      @entities_dirty = false
      @entities
    end
  end
  
  class HtmlBowlerMapper < BowlerMapper
    
  end
end
  
if __FILE__ == $0
  require '../../qipowl'
  y = Qipowl::Mappers::BowlerMapper.new 'html'
  require 'awesome_print'
  ap y[:mail]
end