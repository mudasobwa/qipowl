# encoding: utf-8

require 'yaml'
require 'uri'

module Typogrowl
  class ::String
    RUBY_SYMBOLS = '\'"-(){}\[\].,:;!?~+*/%<>&|^=`'
    CODEPOINT_ORIGIN = 0x24D0
    BOWLED_SYMBOLS = Hash[* RUBY_SYMBOLS.split(//).map { |s|
      [s, [(RUBY_SYMBOLS.index(s) + CODEPOINT_ORIGIN)].pack("U")]
    }.flatten]
    UNBOWLED_SYMBOLS = BOWLED_SYMBOLS.invert
    BOWL_SYMBOLS = BOWLED_SYMBOLS.values.join
    RUBY_KEYWORDS = %w{__FILE__ __LINE__ alias and begin BEGIN break case 
      class def defined? do else elsif end END ensure false for if in module 
      next nil not or redo rescue retry return self super then true undef 
      unless until when while yield}.map &:to_sym
    
    def bowl!
      r = []
      r << self.gsub!(/[#{RUBY_SYMBOLS}]/, BOWLED_SYMBOLS)
      r << self.gsub!(/(\s)(\d)/, '\1☠\2')
      (
        RUBY_KEYWORDS + Kernel.public_methods +
        Bowler.public_instance_methods - 
        Bowler.public_instance_methods(false) +
        [:respond_to, :method_missing, :in=]
      ).uniq.each { |m|
        r << self.gsub!(/(\p{^L})#{m}/, "\\1☠#{m}")
      }
      (r - [nil]).empty? ? nil : self
    end
    def bowl
      self.dup.bowl!
    end
    def unbowl!
      r = []
      r << self.gsub!(/[#{BOWL_SYMBOLS}]/, UNBOWLED_SYMBOLS)
      r << self.gsub!(/☠/, '')
      (r - [nil]).empty? ? nil : self
    end
    def unbowl
      self.dup.unbowl!
    end
  end
  
  class Bowler
    attr_reader :in, :out
    
    SEPARATOR = $, || ' '
    
    def in= str
      @in = str
      defreeze
      roast
      serveup
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

  private
    def initialize
      file = self.class.name.downcase.split('::').last
      @mapping = YAML.load_file "#{File.dirname(__FILE__)}/../../tagmaps/#{file}.yaml"
    end
    
    def orphan str
      str
    end

    def harvest str
      @yielded << str
      nil
    end
    
    def defreeze
      @courses = @in.bowl.split /\R{2}/
      @courses.map! { |dish| 
        dish.gsub! /\R/, ' '
        puts "DISH: |#{dish}|"
        @mapping[:synsugar].each { |re, subst|
          dish.gsub! /#{re}/, subst
        } if @mapping[:synsugar]
        dish
      }.reverse!
    end
    def roast
      @yielded = []
      @courses.each {|dish|
        rest = eval(dish)
        rest = rest.flatten.join(SEPARATOR) if Array === rest
        @yielded << orphan(rest) if rest 
      } unless @courses.nil?
      @out = @yielded.reverse.join("\n")
    end
    def serveup
      puts '='*40
      puts @yielded
      puts '='*40
      @out.unbowl!
    end
  end
end

