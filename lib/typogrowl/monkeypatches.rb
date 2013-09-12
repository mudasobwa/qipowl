# encoding: utf-8

require 'uri'
require_relative 'map'

# monkeypatch to be called to subst selections like ≡bold≡
# with as many repetitions of “≡” as specified
class String
  class << self
    def ␣ ; '\u{00A0}' ; end            # fuck ruby constant naming principle
    def ␢ ; '[\u{00A0}\s]' ; end
    def ␢‖␢ ; '\u{00A0}|\s|^' ; end
  end
  
  AFTER_␣ = "(?<!#{String::␣})"
  AFTER_␢ = "(?<=#{String::␣}|^|$)"
  AFTER_☭ = "(?<=#{String::␢‖␢}|^|#{Typogrowl::Map::TAGS_NOT_ONE_OF})"
  def tg_styling tg, count=1
    str = self.dup
    2.times { |fwd| 
      count.downto(1).each { |i|
        pattern = tg*i
        subster = "☭#{i}".to_sym

        str = fwd.zero? ? # is it a first pass?
            str.gsub(/#{AFTER_␣}#{pattern}(.+?)#{pattern}/m, "#{subster} 〈\\1〉")     # well-formed tags
               .gsub(/#{AFTER_␣}#{pattern}(.+?)(?=(\s|$|\Z))/m, "#{subster} 〈\\1〉") :  # there were no closing “tag”
            str.gsub(/#{subster}/, "#{pattern}") # turn ’em back
      }
    }
    str
  end
  def tg_link tg, starting=nil, ending=nil
    str = self.gsub(/([^\s#{Typogrowl::Map::TAGS_RESTRICTED}]+?)¹(#{starting}\S*?(?:#{ending}))(?=(\s|$|\Z))/m, "#{tg} 〈\\1‖\\2〉")
    str =  str.gsub(/(?<=#{String::␢‖␢})(#{starting}\S*?(?:#{ending}))/m, "#{tg} 〈\\1〉")\
      unless starting.nil?
    str
  end
  def tg_abbr tg
    self.gsub /(\S+)#{tg}(.*?)(?:#{tg}|$|\Z)/m, "#{tg} 〈\\1‖\\2〉"
  end
  def tg_simple tg
    self.gsub /#{AFTER_␣}#{tg}#{String::␢}*(\S+)/, "#{tg} 〈\\1〉"
  end
  def tg_void tg
    self.gsub /#{tg}/, "#{tg} 〈 〉"
  end
  def tg_line tg, tg_sup=nil, tg_sub=nil
    dsl = "#{tg} 〈\\1〉"
    if tg_sub && Typogrowl::Map::inline?(tg_sub)
      re_sub = "([^#{tg_sub}]+)#{tg_sub}" 
      dsl << " #{tg_sub} 〈\\2〉\n"
    end
    self.gsub(/(#{AFTER_␣}#{tg}#{re_sub}[^#{tg}\n]+(\Z|\n))+/m) { |m|
      # FIXME This will fail on ul inside blockquotes!!
      # » <ul><li>nested list item 1</li></ul>
      # » <ul><li>nested list item 2</li></ul>
      m.gsub!(/\n/, '')
      m.gsub!(/#{tg}#{re_sub}([^#{tg}\n]+)/, dsl)
      "#{Typogrowl::Map::TAGS[tg_sup].first} 〈#{m}〉\n" if tg_sup
     }
  end
  def tg_block tg
    self.gsub(/(#{AFTER_␣}#{tg}[^#{tg}\n]+(\Z|\n))+/m) { |m|
      m.gsub!(/[#{tg}]/, ' ')
      "#{tg} 〈#{m}〉\n"
    }
  end
  def uri?
    URI.regexp =~ self
  end
end
