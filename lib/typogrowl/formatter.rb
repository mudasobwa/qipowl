# encoding: utf-8

module Typogrowl
  module Formatter
    module HTML
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
        raise ArgumentError.new "Parameters must be a hash" unless Hash === params
        "#{OPENING[tag, params]}#{text}#{CLOSING[tag]}"
      end
      module_function :tagify
    end
  end
end
