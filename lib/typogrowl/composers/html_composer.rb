# encoding: utf-8

module Typogrowl
  module HtmlFormatter
    TAG_SPLITTER = /†/
    @@split = lambda { |tag| tag.to_s.split TAG_SPLITTER }

    # Opening tag in HTML. Accepts parameters (e. g. for anchors) and
    # class definition via dagger concatenator for tag.
    # The summing up: 
    #     OPENING.call('a†important', {:href='/'})
    # will result in:
    #     <a href='/' class='important'>
    OPENING = lambda { |tag, params|
      tag, *classes = @@split[tag]
      str = "<#{tag}"
      str << " class='#{classes.join ' '}'" unless classes.empty?
      params.each { |k,v|
        str << " #{k}='#{v.gsub /'/, '’'}'"
      }
      str << '>'
    }
    CLOSING = lambda { |tag| "</#{@@split[tag].first}>" }

    # public method to be called from outside
    def tagify text, tag, params={}
      puts "Using tag=[#{tag}]"
      raise ArgumentError.new "Parameters must be a hash (#{params})" \
        unless Hash === params || params = []
      "#{OPENING[tag, params]}#{text}#{CLOSING[tag]}"
    end
    module_function :tagify
  end
  
  module HtmlDSL
    METHODS = Tags.∀∀.map &:to_sym

    module ClassMethods
      def respond_to?(method)
        super.respond_to?(method) || METHODS.include?(method)
      end

      def method_missing(method, *args, &block)
        if METHODS.include?(method)
          puts "Method missing: m=[#{method}]"
          method = Tags.tag_key(method)
          puts "Method missing: m=[#{method}]"
          text, *params = args.flatten
          HtmlFormatter.tagify(text, method)
        else
          super.method_missing(method, *args, &block)
        end
      end
      def ⏎ *args
        "<br>"
      end
      def —— *args
        "<hr>"
      end
      def ☠ *args
        ⚓(args)
      end
      
    end
    extend ClassMethods

    def self.included( other )
      other.extend( ClassMethods )
    end
  end
  
  class HtmlComposer
    attr_reader :yaml
    
    def self.parse func, params
      # FIXME Check if this is not safe
      puts "Evaluating: [HtmlDSL.#{func} Array[#{params}].map(&:strip)]"
      result = eval "HtmlDSL.#{func} Array[#{params}].map(&:strip)"
    end
    
    
  private
    DEFAULT_SET = 'html'
    
    def initialize file
      @yaml = YAML.load_file "#{File.dirname(__FILE__)}/../../tagmaps/#{file}.yaml"
    end

    @@instance = HtmlComposer.new(DEFAULT_SET)
    
    def self.instance 
      @@instance
    end
        
    private_class_method :new  
  end
end
