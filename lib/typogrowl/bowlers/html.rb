# encoding: utf-8

require_relative '../core/bowler'

module Typogrowl
  class Html < Bowler
    def ☀ *args
      harvest(tagify(@mapping[__callee__], args))
    end
    
    def ☼ *args
      tagify(@mapping[__callee__], args)
    end
    
    alias :• :☀
    alias :◦ :☀

    def ▶ *args
      @dt, @dd = args.join(SEPARATOR).split(/\s*—\s*/)
      harvest "<dt>#{@dt}</dt><dd>#{@dd}</dd>"
      nil
    end
  private
    def initialize
      super
      @mapping[:inplace].each do |tag|
        Html.class_eval %Q{
          alias :#{tag} :☼
        }
      end
    end

    def tagify tag, *args
      tag, *clazz = tag.to_s.split('†')
      clazz = clazz.empty? ? nil : " class='#{clazz.join(' ')}'"
      "<#{tag}#{clazz}>#{args.join(SEPARATOR)}</#{tag}>"
    end
    
    def special_handler method, *args, &block
      # Inplace tags, like “≡” for ≡bold decoration≡ 
      @mapping[:inplace].each { |tag|
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
▶ P — 2
• 3
◦ 4
◦ 4 instance_exec bye!'


puts "B: #{tg.in},\n\nUB: #{tg.out}"
