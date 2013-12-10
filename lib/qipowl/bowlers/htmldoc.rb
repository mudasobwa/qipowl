# encoding: utf-8

require 'nokogiri'
require 'fileutils'
require 'yaml'
require_relative '../core/monkeypatches.rb'
require_relative '../utils/hash_recursive_merge.rb'

module Qipowl

  class HtmlDoc < Nokogiri::XML::SAX::Document
    attr_reader :qp, :tags
    def initialize mapping
      @mapping = mapping
      @inside = nil
      @collector = {}
      @tags = {:inplace => {}, :linewide => {}}
      @qp = ''
      @level = 0
    end

    def start_element name, attributes = []
      current_attrs = Hash[attributes]
      
      @qp +=  case name.to_sym
              when :p, :div
                if current_attrs['class']
                  @collector[name.to_sym] = "✿_#{name.to_sym}_#{current_attrs['class'].gsub(/\s+/, '_')}".to_sym
                  @tags[:linewide][@collector[name.to_sym]] = "#{name.to_sym}†#{current_attrs['class'].gsub(/\s+/, '†')}".to_sym
                  "\n\n#{@collector[name.to_sym]} "
                else
                  "\n\n"
                end
              when :ul, :ol, :table, :dl
                @inside = name.to_sym
                "\n"
              when :pre then "\n\nΛ\n"
              when :tr then " ┇ "
              when :td then " ┆ "
              when :a
                @inside = :a
                @collector[:href] = current_attrs['href']
                @collector[:name] = current_attrs['name']
                ''
              when :li then (@inside == :ol) ? "◦ " : "• "
              when :b, :strong then "≡"
              when :i, :em, :nobr then "≈"
              when :strike, :del, :s then "─"
              when :small then "↓"
              when :u then "▁"
              when :code, :tt then "λ"
              when :dfn, :abbr, :cite
                @inside = name.to_sym
                @collector[:title] = current_attrs['title']
              when :hr then "\n\n——\n\n"
              when :br then " ⏎\n"
              when :center then "\n— "
              when :dt then "▷ "
              when :dd then " — "
              when :h1 then "§1 "
              when :h2 then "§2 "
              when :h3 then "§3 "
              when :h4 then "§4 "
              when :h5 then "§5 "
              when :h6 then "§6 "
              when :blockquote then "\n\n〉 "
              when :figure
                @inside = :figure
                "\n\n"
              when :figcaption then " "
              when :img then fix_href(current_attrs['src'])
              when :span, :sup
                if current_attrs['class'].nil?
                  ''
                else
                  @collector[name.to_sym] = "✿_span_#{current_attrs['class'].gsub(/\s+/, '_')}".to_sym
                  @tags[:inplace][@collector[name.to_sym]] = "span†#{current_attrs['class'].gsub(/\s+/, '†')}".to_sym
                  " #{@collector[name.to_sym]}"
                end
              when :embed, :iframe then "\n\n#{current_attrs['src']}\n\n"
              when :html, :body, :object, :param, :thead, :tbody, :font, :'lj-embed', :'lj-cut'
                ''
              else
                raise "=== Unhandled: #{name} with attrs: [#{current_attrs}]"
                ''
              end
    end

    def characters str
      case @inside 
      when :a, :dfn, :abbr
        @collector[:text] = str
      else
        @qp += str
      end
    end

    def end_element name
      @qp +=  case name.to_sym
              when :p, :div
                @collector.delete(name.to_sym)
                "\n\n"
              when :a
                @inside = nil
                (href= @collector.delete(:href)) ?
                  " #{(@collector.delete(:text) || '').gsub(/\s+/, "\u{00A0}")}¹#{fix_href href} " :
                  "☇ #{@collector.delete(:name)} #{@collector.delete(:text)}"
              when :dfn, :abbr, :cite
                @inside = nil
                result = " #{@collector.delete(:text).gsub(/\s+/, "\u{00A0}")}†#{@collector.delete(:title)}† " rescue ''
                result
              when :ul, :ol, :table, :dl
                @inside = nil
                "\n"
              when :li then "\n"
              when :pre then "\nΛ\n\n"
              when :b, :strong then "≡"
              when :i, :em, :nobr then "≈"
              when :u then "▁"
              when :dd then "\n"
              when :strike, :del, :s then "─"
              when :small then "↓"
              when :code, :tt then "λ"
              when :span, :sup
                "#{@collector.delete(name.to_sym)} "
              when :h1, :h2, :h3, :h4, :h5, :h6 then "\n\n"
              when :blockquote then "\n\n"
              when :figure
                @inside = nil
                "\n\n"
              else
                ''
              end
    end
    
  private
    def fix_href href, site = 'http://mudasobwa.ru/'
      href.start_with?('http') ? href : href.gsub(/\A\/+/, '').prepend(site)
    end
  end

end

if __FILE__ == $0
  
def prepare str
  str.gsub(/&[nm]dash;/, '—')            # dashes
     .gsub(/&nbsp;/, ' ')            # dashes
     .gsub(/\s+--\s+/, ' — ')            # dashes
     .gsub(/^\s*/, '')            # leading spaces
     .gsub(/<img src="\/i\/>/, '')
     .gsub(/&trade;/, '™')               # other entities
     .gsub(/&copy;/, '©')               # other entities
     .gsub(/(1st@1stone.ru|am@secondiary.ru)/, 'am@mudasobwa.ru')
     .gsub(/http:\/\/(www\.)?(secondiary|1stone|matiouchkine.net)\.ru/, 'http://mudasobwa.ru')  # obsolete site name
     .gsub(/\[(http[^\]]*)\]/, '\1')     # obsolete markdown pics
     .gsub(/<span>\s*<\/span>/, 'λ\1λ')     # obsolete markdown pics
     .gsub(/<lj (?:comm|user)="(.*?)">/, '✎ \1')     # obsolete markdown pics
     .gsub(/<([^<>]*?@[^<>]*?)>/, '\1')     # obsolete markdown pics
     .gsub(/<imgsrc=/, '<img src=')     # obsolete markdown pics
     .gsub(/<ahref=/, '<a href=')     # obsolete markdown pics
     .gsub(/<\/p>\s*<p>\s*—/, " ⏎\n—")  # direct speech
     .gsub(/<br(?:\s*\/?\s*)>\s*<br(?:\s*\/?\s*)>/, "\n\n")  # old-fashioned carriage     
     .gsub(/<[!]--[^<>]*?-->/, '')            # comments
#     .gsub(/([\.,:;!?])(?=\S)/, '\1 ')            # fix punctuation
end

def postpare str
  str.gsub(/\R{2,}/, "\n\n")
     .gsub(/\A(\s|⏎)*/, '')
     .gsub(/(\s|⏎)*\Z/, '')
end

tags = {
  :magnet => {:✎ => :lj, :☇ => :a},
  :inplace => {:▁ => :u, :─ => :del},
  :linewide => {:☛ => :twit},
  :block => {:✁ => :cut}
}
file = "#{File.dirname(__FILE__)}/../../../data/internals/posts.csv"
file_errors = "#{File.dirname(__FILE__)}/../../../data/internals/errors.txt"
FileUtils.rm file_errors if File.exist? file_errors

FileUtils.mkdir("#{File.dirname(__FILE__)}/../../../data/site")                
# %w{txt pic ref twt}.each {|d| FileUtils.mkdir("#{File.dirname(__FILE__)}/../../../data/site/#{d}")}

puts "Reading #{file} …"
File.readlines(file).each { |l|
  data = l.split('☢')
  puts "Processing record #{data[0]}"
  begin
    html_doc = Qipowl::HtmlDoc.new nil
    parser = Nokogiri::HTML::SAX::Parser.new(html_doc)
    parser.parse(prepare data[2])
    tags.rmerge! html_doc.tags
    body = postpare(html_doc.qp)
    
    body = body.strip if body
    
    id    = data[0]
    title = data[1].gsub(/'/, "’")
    date  = data[3]
    img   = data[4]

    if img && !img.empty? && !img.start_with?('http://')
      img = "http://mudasobwa.ru/i/#{img.gsub(/\A\/+/, '')}"
    end
    
    q_doc = Qipowl::HtmlDoc.new nil
    q_parser = Nokogiri::HTML::SAX::Parser.new(q_doc)
    q_parser.parse(prepare data[5])
    tags.rmerge! q_doc.tags
    quote = postpare(q_doc.qp)

    q_url = data[6]
    type  = data[7].to_i  # 1 => text, 2 => image, 3 => quote, 4 => twit
    stype = case type
            when 1 then :txt
            when 2 then :pic
            when 3 then :ref
            when 4 then :twt
            else :txt
            end
  
    owl_text = %Q(---
title: '#{title}'
id: #{id}
date: '#{date}'
categories: [#{stype}]
---

)
#    owl_text << (type == 4 ? "☛ " : "§1 ")
#    owl_text << title
#    owl_text << "\n\n"

    owl_text << case type
                when 2
                  "#{img} #{body.gsub(/\R/, ' ⏎ ')}"
                when 3
                  q_ref = q_url[/http:\/\/(.*?)\/|\Z/, 1].split('.').last(2).join('.') rescue nil
                  "\n〉 #{quote.strip}\n‒ #{q_ref ? q_ref : q_url}, #{q_url}\n\n#{body}"
                else body
                end

    fname = "#{date.split.first}-#{title.to_filename}.owl"
    fname = (1..100).each {|i|
      break "#{date.split.first}-#{title.to_filename}-#{i}.owl" \
        unless File.exist?("#{File.dirname(__FILE__)}/../../../data/site/#{date.split.first}-#{title.to_filename}-#{i}.owl")
    } if File.exist?("#{File.dirname(__FILE__)}/../../../data/site/#{fname}")
    File.open("#{File.dirname(__FILE__)}/../../../data/site/#{fname}", 'a') { |f| f.write(owl_text) }

  rescue Exception => e
    puts '—'*40
    puts 'Error occured'
    puts prepare(data[2])
    puts '—'*40
    puts prepare(data[5])
    puts '—'*40
    raise e
  end
}

File.open("#{File.dirname(__FILE__)}/../../../data/site/rules.yaml", 'a') { |f|
  f.write(tags.to_yaml)
}

end