# encoding: utf-8

require_relative '../core/bowler'

module Typogrowl
  class Html < Bowler
    def ☀ *args
      puts "ARGS: #{args}"
      harvest(tagify(@mapping[:linewide][__callee__], args)) # EVAL!!!
#       tagify(@mapping[:linewide][__callee__], args)
    end
    
    def ☼ *args
      tagify(@mapping[:inplace][__callee__], args)
    end

    def ▶ *args
      dt, dd = args.join(SEPARATOR).split(/\s*—\s*/)
      harvest "<dt>#{dt}</dt><dd>#{dd}</dd>"
    end
    
    def ⚓ *args
      href, *title = args.flatten
      "<a href='#{href}'>#{title.join(SEPARATOR)}</a>"
    end
    
    def † *args
      term, *title = args.flatten
      "<abbr title='#{title.join(SEPARATOR)}'>#{term}</abbr>"
    end
  private
    def initialize
      super
      {:linewide => :☀, :inplace => :☼}.each { |section, meth|
        @mapping[section].each { |tag, htmltag|
          Html.class_eval %Q{
            alias :#{tag} :#{meth}
          } unless self.class.instance_methods(false).include?(tag)
        }
      }
    end
    
    def tagify tag, *args
      tag, *clazz = tag.to_s.split('†')
      clazz = clazz.empty? ? nil : " class='#{clazz.join(' ')}'"
      "<#{tag}#{clazz}>#{args.join(SEPARATOR).strip}</#{tag}>"
    end

    def orphan str
      "<p>#{str.strip}</p>"
    end
    
    def special_handler method, *args, &block
      # Inplace tags, like “≡” for ≡bold decoration≡ 
      @mapping[:inplace].each { |tag, htmltag|
        if method.to_s.start_with? tag.to_s
          return [method, args].flatten.join(SEPARATOR).gsub(/#{tag}(.*?)(#{tag}|\Z)/) { |m|
            puts "Tag: |#{tag}|, Eval: |#{$1}|"
            send(tag, eval($1)).bowl
          }.split(SEPARATOR)
        end
      }
      [method, args].flatten
    end
  end
end

tg =  Typogrowl::Html.new

tg.in = 'welcome! 
▶ Q — 1 trtr ≈eval instance_exec≈  ≡λghgh ghghλ≡ ghgh
▶ P — 2 I like Markdown¹http://daringfireball.net/projects/markdown/syntax
• 3 Wiki†Best online 
knowledge base ever†
• ◦ 4
• ◦ 4 instance_exec bye!

» Blockquote 1 asd
» • Nested 1
» • Nested 2
» Blockquote 2
'

puts "B: #{tg.in},\n\nUB: #{tg.out}"
