# encoding: utf-8

# Preparse: parse specific cases and ensure DSL well-formness 
# If the inline marker is found in paragraph leading position,
#    it applies to the whole paragraph
module Typogrowl
  # Within all the elements, which might be non-single-word, there are three
  # ways to use: 
  # • one word ⇒ OK
  # • all words, concatenated with non-br spaces ⇒ OK
  # • brackets 〈〉 ⇒ OK
  #
  # Comments: 
  # • inline ✎
  # • block  ✍
  #
  # Carriage return:
  # • ⏎
  # 
  # Data Lists:
  # ∃ DT ∈ DD
  # TODO: maybe there is no need to acquire the preceeding ∃
  #
  # Blockquotes:
  # If there is a line, starting with emdash within blockquote, it’s
  #    a reference (bootstrap’s «small».
  # If the reference ends with «, http\s*», it’s a link
  
  module Map
    FILENAME_SYMBOLS = {
      '#'  => ['＃', '﹟', '♯'],
      '?'  => ['？', '﹖'],
      '&'  => ['＆', '﹠'],
      '@'  => ['＠', '﹫'],
      '\\' => ['＼'],
      '/'  => ['／'],
      ' '  => ["\u{00A0}"]
    }.inject({}) { |h,(k,v)| h[k]=v.first; h }
    
    TAGS_COMPOSE_BLOCK = {
      :p_lead          => ['¶', '⇑'],                         # lead
      :p_text_right    => ['⇒'],                              # right aligned
      :p_text_center   => ['⇓'],                              # center aligned
      :p_text_left     => ['⇐'],                              # left aligned
      :p_text_muted    => ['☆'],
      :p_text_primary  => ['★'],
      :p_text_success  => ['☛'],
      :p_text_info     => ['☞'],
      :p_text_warning  => ['☣'],
      :p_text_danger   => ['☢', '☠'],
      :blockquote_pull_right => ['»»'],       # <blockquote class="pull-right">
      :dl_horizontal   => ['∌']                               # horizontal dl
    }      
    
    TAGS_COMPOSE_INLINE = {
      :abbr_phone      => ['☎'],
      :a_email         => ['✉'],
      :dt_horizontal   => ['▷']                               # horizontal dl
    }
    TAGS_COMPOSE = {}
     .merge(TAGS_COMPOSE_BLOCK) { |k, f, s| f + s }
     .merge(TAGS_COMPOSE_INLINE) { |k, f, s| f + s }
    
    TAGS_BLOCK = {
      :hr           => ['——'],
      :comment      => ['✎', '✍'],
      # block elements 
      :p            => ['❡'],
      :blockquote   => ['»'],
      :dl           => ['∋'],
      :address      => ['℁'],
      :pre          => ['Λ'],
    }.merge(TAGS_COMPOSE_BLOCK) { |k, f, s| f + s }
    # <h1> ≡ '§', <h2> ≡ '§§' etc.
    (1..6).each { |i| TAGS_BLOCK["h#{i}".to_sym] = ['§'*i] }
    
    TAGS_ALL_SUFFICIENT = {
      :br           => ['⏎']
    }

    TAGS_INLINE = {
      # nested (2nd level)
      :blockquote   => ['“'],
      # inline elements
      :li           => ['•', '◦', '‣', '∙', '⁃'],
      :small        => ['↓'],
      :dt           => ['▶'],
      :dd           => ['—'],
      :b            => ['≡≡'],   # proceed before strong
      :strong       => ['≡'],  
      :i            => ['≈≈'],   # proceed before em
      :em           => ['≈'],
      :abbr         => ['†'],
      :code         => ['λ'],
    }.merge(TAGS_COMPOSE_INLINE) { |k, f, s| f + s }
     .merge(TAGS_ALL_SUFFICIENT) { |k, f, s| f + s }

    TAGS = {
      # not directly used block elements      
      :figure       => ['⚑'],
      :ol           => ['∃'],
      :ul           => ['∀'],
      # not directly used inline elements
      :dd           => ['∈'],
      :a            => ['⚓'],
      :img          => ['⚐'],
      
      # possibly redundants
      :author       => ['Ⓐ', 'ⓐ']
    }.merge(TAGS_BLOCK)   { |k, f, s| f + s }
     .merge(TAGS_INLINE)  { |k, f, s| f + s }
     
    TAGS_BLOCKQUOTES = TAGS.select { |k, v|
      k.to_s.start_with? 'blockquote'
    }
    TAGS_BLOCKQUOTES_RE = TAGS_BLOCKQUOTES.values.flatten.join '|'

    def stringify tags=:all
      case tags
      when :block   then TAGS_BLOCK
      when :inline  then TAGS_INLINE
      when :compose then TAGS_COMPOSE
      else TAGS
      end.values.flatten.join.split(//).uniq.join
    end
    
    def regexpify tags=:all
      /(?<!\u{00A0})[#{stringify(tags)}]/
    end
    
    def inline? str
      !!(/#{TAGS_RE}/ =~ str)
    end
    
    def block? str
      !!(str && (str.length > 0) && /#{regexpify(:block)}/ =~ str[0])
    end
    
    def tag tg
      TAGS.select { |key, hash| hash.include? tg.to_s }.keys.first
    end
    
    def same_tag? tg1, tg2
      tag(tg1) == tag(tg2)
    end
    
    # FIXME
    def html tg, content
      html_tag, *clazz = tag(tg).to_s.split /_/
      clazz = clazz.empty? ? nil : " class='#{clazz.join('-')}'"
      content.strip!
      "<#{html_tag}#{clazz}>" + (content.empty? ? '' : "#{content}</#{html_tag}>") 
    end
    
    module_function :stringify, 
                    :regexpify, 
                    :inline?, 
                    :block?, 
                    :same_tag?, 
                    :tag, 
                    :html
    
    TAGS_STR = stringify
    TAGS_RE  = regexpify
    
    TAGS_RESTRICTED = "〈〉#{TAGS_STR}"
    TAGS_NOT_ONE_OF = TAGS_RESTRICTED.split(//).join('|')
  end
end
