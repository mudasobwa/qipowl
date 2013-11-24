# encoding: utf-8

require 'nokogiri'

module Typogrowl

  class HtmlDoc < Nokogiri::XML::SAX::Document
    attr_reader :tg
    def initialize mapping, str = ''
      @mapping = mapping
      @tg = str
      @level = -1
    end
    def start_element name, attributes = []
      tg_name = name.to_sym # FIXME add “†class” if class is presented in attrs
      @tg +=  case tg_name
              when *@mapping[:enclosures].values
                @level += 1
                "\n\n"
              when *@mapping[:flush].values
                " #{@mapping[:flush].key(tg_name)}\n"
              when *@mapping[:block].values
                "\n\n#{@mapping[:block].key(tg_name)}"
              when *@mapping[:inplace].values
                "#{@mapping[:inplace].key(tg_name)}"
              when *@mapping[:magnet].values
                "#{@mapping[:magnet].key(tg_name)}"
              when *@mapping[:linewide].values
                "#{' '*@level if @level > 0}#{@mapping[:linewide].key(tg_name)} "
              else
                ""
              end
    end
    def characters str
      @tg += str
    end
    def end_element name
      tg_name = name.to_sym # FIXME add “†class” if class is presented in attrs
      puts "End: #{tg_name}"
      @tg +=  case tg_name
              when *@mapping[:enclosures].values
                @level -= 1
                "\n\n"
              when *@mapping[:block].values
                "\n#{@mapping[:block].key(tg_name)}\n\n"
              when *@mapping[:inplace].values
                "#{@mapping[:inplace].key(tg_name)}"
              when *@mapping[:magnet].values
                "\n"
              when *@mapping[:linewide].values
                "\n"
              else
                ""
              end
    end
  end

end