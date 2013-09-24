# encoding: utf-8

require_relative '../tags'

module Typogrowl
  class ComposeHandler
    def initialize composer
      if composer.respond_to?(:parse) 
        @composer = composer
      else
        instance_eval "@composer = Typogrowl::#{composer.capitalize}Composer"
      end
    end
    def show str
      puts '='*40
      puts str
      puts '='*40
    end
    def compose str
      re = /(?<func>#{Tags.∃∃})\((?<params>[^()]*)\)/
      while str.gsub!(re) { |m| 
          @composer.parse($~[:func], $~[:params]) 
      } do ; end
      str
    end
  end
end
