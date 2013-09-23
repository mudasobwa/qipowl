# encoding: utf-8

require 'yaml'

require_relative '../utils/logging'

module Typograph
  class MalformedRulesFile < Exception 
  end
  class Parser
    class << self 
      include TypoLogging
    end
    attr_accessor :yaml
    
    def self.parse str, lang = :default
      lang = lang.to_sym
      instance.yaml.each { |k, values|
        values.each { |k, v|
          if !!v[:re]
            v[lang] = v[:default] if (!v[lang] || v[lang].size.zero?)
            raise MalformedRulesFile.new "Malformed rules file (no subst for #{v})" \
              if !v[lang] || v[lang].size.zero?
            substituted = !!v[:pattern] ?
                str.gsub!(/#{v[:re]}/) { |m| m.gsub(/#{v[:pattern]}/, v[lang].first) } :
                str.gsub!(/#{v[:re]}/, v[lang].first)
            logger.warn "Unsafe substitutions were made to source:\n# ⇒ #{str}"\
              if v[:alert] && substituted
            if v[lang].size > 1
              str.gsub!(/#{v[lang].first}/) { |m|
                prev = $`
                obsoletes = prev.count(v[lang].join)
                obsoletes -= prev.count(values[v[:compliant].to_sym][lang].join) \
                  if !!v[:compliant]
                !!v[:slave] ?
                  obsoletes -= prev.count(v[:original]) + 1 :
                  obsoletes += prev.count(v[:original])
                
                v[lang][obsoletes % v[lang].size]
              }
            end
          end
        }
      }
      str
    end
  private
    DEFAULT_SET = 'typograph'
    ENTITIES = %w{re}
    
    def initialize file
      @yaml = YAML.load_file "#{File.dirname(__FILE__)}/../../tagmaps/#{file}.yaml"
      @yaml.delete(:placeholder)
    end

    @@instance = Parser.new(DEFAULT_SET)
    
    def self.instance 
      @@instance
    end
        
    private_class_method :new  
  end
end

