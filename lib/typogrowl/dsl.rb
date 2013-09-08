# encoding: utf-8
 
module Typogrowl
  module DSL
    METHODS = Map::TAGS.values.flatten.map(&:to_sym)

    module ClassMethods
      def respond_to?(method)
        super.respond_to?(method) || METHODS.include?(method)
      end

      def method_missing(method, *args, &block)
        if METHODS.include?(method)
          case method
          when :⚓, :†
            out_tag, in_tag = args[0].split /‖/
            attr = (:⚓ == method) ? 'href' : 'title'
            "<#{Map::tag(method)} #{attr}='#{in_tag}'>#{out_tag}</a>"
          else
            Map::html method, *args
          end
        else
          super.method_missing(method, *args, &block)
        end
      end
      
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