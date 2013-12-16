# encoding: utf-8

require_relative '../utils/hash_recursive_merge'

module Qipowl
  class ::Array
    # Checks whether an array contains non-nil elements
    # @return +true+ if an array does not contain non-nils and +false+ otherwise
    def vacant?
      (self.flatten - [nil]).empty?
    end
  end

  # Bowling string means producing interpreter-safe text basing on ascii input.
  # 
  class ::String
    NBSP = "\u{00A0}"
    
    SYMBOL_FOR_SPACE = "\u{2420}" # ␠
    
    WIDESPACE = "\u{FF00}"
    EN_SPACE = "\u{2002}"
    EM_SPACE = "\u{2003}"
    THREE_PER_EM_SPACE = "\u{2004}"
    FOUR_PER_EM_SPACE = "\u{2005}"
    SIX_PER_EM_SPACE = "\u{2006}"
    FIGURE_SPACE = "\u{2007}"
    PUNCTUATION_SPACE = "\u{2008}"
    THIN_SPACE = "\u{2009}"
    HAIR_SPACE = "\u{200A}"
    ZERO_WIDTH_SPACE = "\u{200B}"
    NARROW_NO_BREAK_SPACE = "\u{202F}"
    MEDIUM_MATHEMATICAL_SPACE = "\u{205F}"
    ZERO_WIDTH_NO_BREAK_SPACE = "\u{FEFF}"
    IDEOGRAPHIC_SPACE = "\u{3000}"    
    
    CARRIAGE_RETURN = '␍'
    NULL = '␀'
    ASCII_SYMBOLS, ASCII_DIGITS, ASCII_LETTERS_SMALL, ASCII_LETTERS_CAP = [
        [(0x21..0x2F), (0x3A..0x40), (0x5B..0x60), (0x7B..0x7E)],
        [(0x30..0x39)],
        [(0x61..0x7A)],
        [(0x41..0x5A)]
    ].map { |current| current.map(&:to_a).flatten.map { |i| [i].pack('U') } }
    ASCII_ALL = [ASCII_SYMBOLS, ASCII_DIGITS, ASCII_LETTERS_SMALL, ASCII_LETTERS_CAP]

    CODEPOINT_ORIGIN = 0xFF00 - 0x0020 # For FULLWIDTH characters

    UTF_SYMBOLS, UTF_DIGITS, UTF_LETTERS_SMALL, UTF_LETTERS_CAP = ASCII_ALL.map { |current|
      Hash[* current.join.each_codepoint.map { |char|
        [[char].pack("U"), [char + CODEPOINT_ORIGIN].pack("U")]
      }.flatten]
    }
    UTF_ALL = [UTF_SYMBOLS.values, UTF_DIGITS.values, UTF_LETTERS_SMALL.values, UTF_LETTERS_CAP.values]
    
    UTF_ASCII = UTF_SYMBOLS.merge(UTF_DIGITS).merge(UTF_LETTERS_SMALL).merge(UTF_LETTERS_CAP)
    ASCII_UTF = UTF_ASCII.invert
    
    def vacant?
      nil? || empty?
    end
    
    def hsub! hash
      self.gsub!(/#{hash.keys.join('|')}/, hash)
    end
    def hsub hash
      (out = self.dup).hsub! hash
      out
    end
    def bowl!
      self.gsub!(/[#{Regexp.quote(ASCII_ALL.join)}]/, UTF_ASCII)
    end
    def bowl
      (out = self.dup).bowl!
      out
    end
    def unbowl!
      self.gsub!(/[#{Regexp.quote(UTF_ALL.join)}]/, ASCII_UTF)
    end
    def unbowl
      (out = self.dup).unbowl!
      out
    end
    def spacefy!
      self.gsub!(/ /, SYMBOL_FOR_SPACE)
    end
    def spacefy
      (out = self.dup).spacefy!
      out
    end
    def unspacefy!
      self.gsub!(/#{SYMBOL_FOR_SPACE}/, ' ')
    end
    def unspacefy
      (out = self.dup).unspacefy!
      out
    end
    
    def unuglify
      self.unbowl.unspacefy.uncarriage.strip
    end

    HTML_ENTITIES = Hash[[['<', 'lt'], ['>', 'gt'], ['&', 'amp']].map { |k, v| [k.bowl, "&#{v};"] }]

    def carriage
      self.gsub(/\R/, " #{CARRIAGE_RETURN} ")
    end
    def carriage!
      self.gsub!(/\R/, " #{CARRIAGE_RETURN} ")
    end
    def uncarriage
      self.gsub(/[[:blank:]]?#{CARRIAGE_RETURN}[[:blank:]]?/, %Q(
))
    end
    def uncarriage!
      self.gsub!(/[[:blank:]]?#{CARRIAGE_RETURN}[[:blank:]]?/, %Q(
))
    end

    def un␚ify
      self.gsub(/␚(.*?)␚/, '')
    end
    
    def wstrip
      self.gsub(/#{NBSP}/, '')
    end
    
    def to_filename
      self.gsub(/[#{Regexp.quote(ASCII_SYMBOLS.join)}]/, UTF_ASCII).gsub(/\s/, "#{NBSP}")[0..50]
    end
  end
  
  class ::Symbol
    def bowl
      self.to_s.bowl.to_sym
    end
    def unbowl
      self.to_s.unbowl.to_sym
    end
    def spacefy
      self.to_s.spacefy.to_sym
    end
    def unspacefy
      self.to_s.unspacefy.to_sym
    end
    def unuglify
      self.to_s.unuglify.to_sym
    end
    def wstrip
      self.to_s.wstrip.to_sym
    end
  end
  
  class ::Fixnum
    def ␚ify
      "␚#{self}␚"
    end
  end
    
end
