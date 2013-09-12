# encoding: utf-8

require_relative 'monkeypatches'

module Typogrowl
  module DSL
    METHODS = Map::TAGS.values.flatten.map(&:to_sym)

    module ClassMethods
      def respond_to?(method)
        super.respond_to?(method) || METHODS.include?(method)
      end

      def method_missing(method, *args, &block)
        METHODS.include?(method) ? 
            Map::html(method, *args) :
            super.method_missing(method, *args, &block)
      end
      
      def ⚓ arg
        out_tag, in_tag = arg.split /‖/
        method, attr = in_tag.uri? ?
          [:⚓, 'href'] : [:†, 'title']
        "<#{Map::tag(method)} #{attr}='#{in_tag}'>#{out_tag}</#{Map::tag(method)}>"
      end
      alias_method :†, :⚓

      def ✉ arg
        " ✉ <a href='mailto:#{arg}'>#{arg}</a>"
      end
      def ☎ arg
        " ☎ <abbr title='Phone'>#{arg}</abbr>"
      end
    end
    extend ClassMethods

    def self.included( other )
      other.extend( ClassMethods )
    end
  end
end