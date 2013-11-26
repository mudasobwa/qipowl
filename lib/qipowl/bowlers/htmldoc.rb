# encoding: utf-8

require 'nokogiri'

module Qipowl

  class HtmlDoc < Nokogiri::XML::SAX::Document
    attr_reader :qp
    def initialize mapping
      @mapping = mapping
      @current_text = nil
      @current_attrs = {}
      @qp = ''
      @level = 0
    end

    def start_element name, attributes = []
      return if @current_attrs[:a]
      
      @current_attrs[name.to_sym] = Hash[attributes]
      
#      qp_class = @current_attrs[:class].split.first if @current_attrs[:class]
      
      @qp +=  case name.to_sym
              when :p, :ul then "\n\n"
              when :a
                @current_text = ''
                ""
              when :li then "• "
              when :b, :strong then "≡"
              when :i, :em then "≈"
              when :strike, :del then "✁"
              when :small then "↓"
              when :h1 then "§1 "
              when :h2 then "§2 "
              when :h3 then "§3 "
              when :h4 then "§4 "
              when :h5 then "§5 "
              when :h6 then "§6 "
              when :blockquote then "\n\n〉 "
              when :img # FIXME!!! FIGURE!!!
                @current_attrs[:src] || ''
              else
                puts "Unhandled: #{name}"
                ''
              end
    end

    def characters str
      @current_text.nil? ? @qp += str : @current_text += str
    end

    def end_element name
      @qp +=  case name.to_sym
              when :p then "\n\n"
              when :a
                result = "#{@current_text.gsub(/\s+/, ' ')}¹#{@current_attrs[:a]['href']}"
                @current_text = nil
                result
              when :li then "\n"
              when :b, :strong then "≡"
              when :i, :em then "≈"
              when :strike, :del then "✁"
              when :small then "↓"
              when :h1, :h2, :h3, :h4, :h5, :h6 then "\n\n"
              when :blockquote then "\n\n"
              else
                ''
              end
    ensure
      @current_attrs.delete name.to_sym
    end
  end

end

if __FILE__ == $0
  
def prepare str
  str.gsub(/<\/p>\s*<p>\s*—/, " ⏎\n—")  # direct speech
     .gsub(/<br(?:\s*\/?\s*)>\s*<br(?:\s*\/?\s*)>/, "\n\n")  # old-fashioned carriage
     .gsub(/<br(?:\s*\/?\s*)>/, " ⏎\n") # old-fashioned carriage
     .gsub(/&[nm]dash;/, '—')            # dashes
     .gsub(/&trade;/, '™')               # other entities
end

def postpare str
  str.gsub(/\R{2,}/, "\n\n")
end


puts "Reading #{File.dirname(__FILE__)}/../../../data/internals/posts-10.csv …"
File.readlines("#{File.dirname(__FILE__)}/../../../data/internals/posts-10.csv").each { |l|
  data = l.split('☢')[2]

#  puts "line is #{data}"
  
  html_doc = Qipowl::HtmlDoc.new nil
  parser = Nokogiri::HTML::SAX::Parser.new(html_doc)
  parser.parse(prepare data)
  puts '='*40
  puts postpare(html_doc.qp)
  puts '='*40
  
#  break
#   html_doc.tg
}

end