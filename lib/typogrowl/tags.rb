# encoding: utf-8

require 'yaml'
require_relative 'exception'

module Typogrowl
  class Tags
    attr_accessor :yaml

    ENTITIES = %w{tag regexp operator}

    ENTITIES.each do |w|
      class_eval %Q{
        class << self
          def #{w}(key, subset = :all, only_one = true)
            for_key = #{w}s(subset)[key.to_sym] unless #{w}s(subset).nil?
            return nil if for_key.nil? || for_key.empty? 
            only_one ? for_key.first : for_key
          end
          def #{w}s(subset = :all)
            instance.yaml["\#{subset}".to_sym][:#{w}s]
          rescue
            p "IGNORED: $!"
          end
          def #{w}_key(tag, subset = :all)
            keys = #{w}s(subset).select { |k, v| v.include? tag }.keys
            raise Tags::InvalidTypogrowl.new "Found two or more keys for tag \#{tag} in subset \#{subset}" if keys.size > 1
            keys.first unless keys.empty?
          end
        end
      }
    end
    
    class << self
      # @return [String] all the tags except those in `:control` group
      # if the param given is set to `true`
      def ∀ with_controls = false
        res = tags.values
        res -= tags(:control).values unless with_controls
        res.flatten.uniq.join
      end
      def ∃ tag
        tags.select { |k,v| v.include? tag }
      end
      def ← entity, match = true
        "(?<#{match ? '=' : '!'}#{entity})"
      end
      def → entity, match = true
        "(?#{match ? '=' : '!'}#{entity})"
      end
    end

  private   
    DEFAULT_SET = 'markup'
    
    def initialize file
      @yaml = YAML.load_file "#{File.dirname(__FILE__)}/../tagmaps/#{file}.yaml"
      
      @yaml[:all] = ENTITIES.inject({}) { |allmemo, w|
        entity = "#{w}s".to_sym
        allmemo[entity] = @yaml.inject({}) { |memo, subset| 
          Hash === subset.last && !subset.last[entity].nil? ?
            memo.merge(subset.last[entity]) { |k, f, s| f + s } : memo
        }
        allmemo
      }
    end

    @@instance = Tags.new(DEFAULT_SET)
    
    def self.instance 
      @@instance
    end
        
    private_class_method :new  
  end
end
