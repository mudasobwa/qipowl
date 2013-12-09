# encoding: utf-8

require_relative '../core/bowler'

module Qipowl
  
  # Markup processor for Yaml.
  # 
  # This class produces hash from YAML file.
  class Yaml < Bowler
    attr_reader :result
    def initialize file = nil
      super
      merge_rules file if file
    end
    
    def parse_and_roll str
      @result = {}
      @partial = nil
      super str
      @result
    end
    
    # Tupla handler
    def ： *args
      from, till, *rest = args.flatten
      if @partial.nil? or Hash === @partial
        (@partial ||= {})[from.unuglify] = till.unuglify                   
        rest
      else
        harvest :：, args.join(SEPARATOR).unbowl.unspacefy.uncarriage.strip
      end
    end
    
    # Array element handler
    def － *args
      (@partial ||= []) << args.join(SEPARATOR).unuglify
      nil
    end
    
    def harvest callee, str
      if Hash === @partial 
        if str == String::CARRIAGE_RETURN
          key = @partial.keys.last
          @partial.delete key
          @result[key] = @partial
        else
          @result.merge! @partial
        end
      else
        @result[str] = @partial unless str.vacant?
      end
      
      @partial = nil
    end
    
    def self.parse str
      Yaml.new.parse_and_roll str
    end
    
  end

end
