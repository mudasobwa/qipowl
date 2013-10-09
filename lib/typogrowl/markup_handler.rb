# encoding: utf-8

require 'yaml'

module Typogrowl
  class InvalidTypogrowl < SyntaxError
  end
  class MarkupHandler
    attr_reader :yaml
    def tags
      puts @@instance.yaml
    end
  private   
    def initialize file = 'markup'
      @yaml = YAML.load_file "#{File.dirname(__FILE__)}/../tagmaps/#{file}.yaml"
    end
    
    def process section
      section = @yaml[section.to_sym]
      raise InvalidTypogrowl.new 'Invalid section in process' if section.nil?
      
      
    end

    @@instance = MarkupHandler.new
    
    def self.instance 
      @@instance
    end
        
    private_class_method :new      
  end
end

#Typogrowl::MarkupHandler.instance.tags

@result = []
@yielded = []
@current = :¶
def respond_to?(method)
  true
end

def method_missing(method, *args, &block)
  puts "M: #{method}"
  @result.unshift(method)
  nil
end
def • *args
  @li = "<li>#{@result[@current].join(' ')}</li>"
#  puts "Resulting: #{@li}"
  @result = []
  @yielded << @li
  @yielded
end
def ▶ *args
  @dt, @dd = @result[@current].join(' ').split(/\s*—\s*/)
  @di = "<dt>#{@dt}</dt><dd>#{@dd}</dd>"
#  puts "Resulting: #{@li}"
  @result = []
  @yielded << @di
  @yielded
end
mup = '§ Header 1

Lorem ipsum ≡dolor sit amet≡, consectetur adipiscing elit. 
Vivamus quis malesuada sapien. 

• Aenean ipsum erat, euismod at commodo vitae, 
• mollis nec tortor. 

▶ Praesent sed — scelerisque neque 
▶ Aenean nisl ante — lobortis vel dui non¹iaculis ornare libero 

Mauris a pulvinar lectus, at vestibulum elit. 
Donec dignissim ligula id cursus ullamcorper. 
Proin ullamcorper sem sit amet tortor accumsan, 
vel scelerisque lorem ultricies. Quisque nec neque 
at lorem consectetur euismod ac non nulla. 

Etiam ultricies nulla neque, nec commodo erat ultricies sed.'

# 1. Subst commas
puts '='*40
• Aenean ipsum erat euismod • at commodo vitae 
▶ Praesent sed — scelerisque neque 
▶ Aenean nisl ante — lobortis vel dui non¹iaculis ornare libero 
puts @yielded
puts '='*40
