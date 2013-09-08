# encoding: utf-8

module Typogrowl  
  module Helpers
    # monkeypatch to be called to subst selections like ≡bold≡
    # with as many repetitions of “≡” as specified
    class ::String
      # lookbehind pattern for NOT non-breakable space
      @@␣ = '(?<!\u{00A0})'
      @@␢ = '(?<=\u{00A0}|\s|^|$)'
      # subst symbol to temporary use in regular expressions
      @@☭ = '☭'
      def tg_styling tg, count=1
        str = self.dup
        2.times { |fwd| 
          count.downto(1).each { |i|
            pattern = tg*i
            subster = "#{@@☭}#{i}".to_sym

            str = fwd.zero? ? # is it a first pass?
                str.gsub(/#{@@␣}#{pattern}(.+?)#{pattern}/m, "#{subster} 〈\\1〉")     # well-formed tags
                   .gsub(/#{@@␣}#{pattern}(.+?)(?=(\s|$|\Z))/m, "#{subster} 〈\\1〉") :  # there were no closing “tag”
                str.gsub(/#{subster}/, "#{pattern}") # turn ’em back
          }
        }
        str
      end
      def tg_link tg, starting=nil, ending=nil
        str = self.gsub(/#{@@␢}(\S+?)¹(#{starting}\S*?(?:#{ending}))(?=(\s|$|\Z))/m, "#{tg} 〈\\1‖\\2〉")
        str =  str.gsub(/#{@@␢}(#{starting}\S*?(?:#{ending}))/m, "#{tg} 〈\\1〉")\
          unless (starting.nil? && ending.nil?)
        str
      end
      def tg_abbr tg
        self.gsub /(\S+)#{tg}(.*?)(?:#{tg}|\Z)/m, "#{tg} 〈\\1‖\\2〉"
      end
      def tg_simple tg
        self.gsub /#{@@␣}#{tg}[\u{00A0}\s]*(\S+)/, "#{tg} 〈\\1〉"
      end
      def tg_void tg
        self.gsub /#{tg}/, "#{tg} 〈 〉"
      end
      def tg_line tg, tg_sup=nil, tg_sub=nil
        dsl = "#{tg} 〈\\1〉"
        if tg_sub && Map::inline?(tg_sub)
          re_sub = "([^#{tg_sub}]+)#{tg_sub}" 
          dsl << " #{tg_sub} 〈\\2〉\n"
        end
        self.gsub(/(#{@@␣}#{tg}#{re_sub}[^#{tg}\n]+(\Z|\n))+/m) { |m|
          # FIXME This will fail on ul inside blockquotes!!
          # » <ul><li>nested list item 1</li></ul>
          # » <ul><li>nested list item 2</li></ul>
          m.gsub!(/\n/, '')
          m.gsub!(/#{tg}#{re_sub}([^#{tg}\n]+)/, dsl)
          "#{Map::TAGS[tg_sup].first} 〈#{m}〉\n" if tg_sup
         }
      end
      def tg_block tg
        self.gsub(/(#{@@␣}#{tg}[^#{tg}\n]+(\Z|\n))+/m) { |m|
          m.gsub!(/[#{tg}]/, ' ')
          "#{tg} 〈#{m}〉\n"
        }
      end
    end
    # FIXME Wellform will fail after two consequent execs on lines for anchor etc
    # FIXME this method after all the tests passed should be made private!!
    def wellform input
      input
           .tg_void('⏎')
           .tg_void('———')
           .tg_styling('≡', 2)
           .tg_styling('≈', 2)
           .tg_styling('↓', 1)
           .tg_styling('λ', 1)
              .tg_link('✇', 'http://www.youtube.com/watch\?v=|http://youtu.be/')
              .tg_link('⚐', 'http', 'jpeg|jpg|gif|png')
              .tg_link('⚓')
              .tg_abbr('†')
            .tg_simple('☎')
            .tg_simple('✉')
              .tg_line('∙', :ul)
              .tg_line('▶', :dl, '—')
              .tg_line('▷', :dl_horizontal, '—')
             .tg_block('“')
    end

    def inlines input
      input = wellform input
      loop do
        input.gsub!(/(?<func>[#{Map::TAGS_STR}]+)[\u{00A0}\s]+〈(?<arg>[^〈〉]+)〉/m) {
          eval "DSL.#{$~[:func]} \"#{$~[:arg].gsub /"/, '\"'}\""
        } 
        break unless $~
      end
      input
    end

    def split input
      current = nil
      input.split(/\n/).inject([]) { |memo, c|
        c.strip!
        if !memo.last
          memo << (Map::block?(c) ? c : "#{Map::TAGS[:p].first} #{c}")
        elsif /\A\Z/ =~ c
          memo << ''
        elsif (Map::block?(c) && 
              !Map::same_tag?(memo.last.split(/\u{00A0}|\s/).first, c.split(/\u{00A0}|\s/).first))
          memo << c
        else
          c.gsub!(/\A[#{Map::TAGS_STR}]+[\u{00A0}\s]+/, '') if memo.last.start_with? c.split(/\u{00A0}|\s/).first
          memo.last << (memo.last.empty? ? "#{Map::TAGS[:p].first} #{c}" : "\n#{c}")
        end
        memo
      }.delete_if &:empty?
    end

    def block input
      raise ArgumentError.new("Block should begin with one of #{Map::TAGS_RE}") \
        unless Map::block? input[0]

      unless /(?<func>\S+)[\u{00A0}\s]*(?<arg>.*)/m =~ input
        raise ArgumentError.new("Block should be well-formed: [\n#{input}\n]") \
      end
      func, arg = $~.captures
      arg = inlines arg
      
      raise ArgumentError.new("Block should not contain controls (#{Map::TAGS_RE}) inside [\n#{arg}\n]") \
        if Map::inline? arg

      inlines("#{func}" + (arg.empty? ? '' : " 〈#{arg}〉")).gsub /\n/, ' '
    end
    
    def process input
      split(input).map { |l|
        block l
      }
    end
    module_function :process
  end
  
  # Monkeypatches
  class ::String
    def tg_inlines
      Helpers.inlines self
    end

    def tg_split
      Helpers.split self
    end
  end
end