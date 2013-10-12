# encoding: utf-8

require 'yaml'
require 'uri'

#require 'typogrowth/string'
require_relative '../../../../typogrowth/lib/typogrowth/string'

require_relative 'monkeypathes'

module Typogrowl
  
  class Bowler
    attr_reader :in, :out
    
    SEPARATOR = $, || ' '
    
    def parse_and_roll str
      serveup roast defreeze @in = str
    end

    def merge_rules file
      @mapping.rmerge!(YAML.load_file.bowl) rescue nil
    end
    
    def respond_to?(method)
      true
    end

    def self.const_missing name
      name
    end
    
    def method_missing method, *args, &block
      method, *args = special_handler(method, *args, &block) \
        if self.private_methods.include?(:special_handler)
      [method, args].flatten
    end

    def initialize file = nil
      file ||= self.class.name.downcase.split('::').last
      file = "#{File.dirname(__FILE__)}/../../tagmaps/#{file}.yaml"
      @mapping = File.exist?(file) ? YAML.load_file(file).bowl : {} 
    end
    
  private
    def orphan str
      str
    end
    
    def harvest callee, str
      @yielded << str
      nil
    end

    def defreeze str
      # FIXME Make this configurable
      raise Exception.new "Reserved symbols are used in input. Aborting…" \
        if /[#{String::BOWL_SYMBOLS}]/ =~ str
      str.bowl
    end

    def roast str
      @yielded = []
      courses = str.split /\R{2}/
      courses.map! { |dish| 
        @mapping[:synsugar].each { |re, subst|
          dish.gsub! /#{re}/, subst
        } if @mapping[:synsugar]
        dish.uncarriage
      }.reverse!
      courses.each {|dish|
        rest = eval(dish)
        rest = rest.flatten.join(SEPARATOR) if Array === rest
        harvest(nil, orphan(rest)) if rest 
      } unless courses.nil?
      @yielded.reverse.join("\n")
    end

    def serveup str
      @out = str.carriage.unbowl
    end
    
    def section tag
      result = @mapping.each { |k, v| 
        break k if Hash === v && v.keys.include?(tag) 
      }
      return Symbol === result ? result : nil
    end
  end
end

