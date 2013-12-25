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
    attr_reader :hash
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
      
      @hash.rmerge!(input.to_hash)
      merge_hook if private_methods.include? :merge_hook
    end
    private
    def load_yaml input
      IO === input ?
        YAML.load_stream(input) :
        YAML.load_file("#{Qipowl.bowlers_dir}/#{input.downcase}.yaml")
    end
  end
  
  class BowlerMapper < Mapper
    def initialize input = nil
      input = self.class.name.gsub(/BowlerMapper\Z/, '') if input.nil?
      super input
    end
    @entities = @synonyms = nil
    def [] entity
      @entities.each { |key, value| # :block. :alone etc
        value.each { |k, v|
          next unless k == entity
          v = {:tag => v} unless Hash === v
          v[:section] = key
          return v
        }
      }
      nil
    end
  private
    def merge_hook
      @synonyms = {}
      @hash[:entities].each { |key, value| # :block. :alone etc
        value.each { |k, v|
          v[:synonyms].each { |syn|
            ((@synonyms[key] ||= {})[syn] = v.dup).delete(:synonyms)
          } if Hash === v && v[:synonyms]
        }
      }
      @entities = @hash[:entities].rmerge(@synonyms)
      @synonyms
    end
  end
  
  class HtmlBowlerMapper < BowlerMapper
    
  end
end
  
if __FILE__ == $0
  require '../../qipowl'
  y = Qipowl::BowlerMapper.new 'html'
  require 'awesome_print'
  ap y[:mail]
end