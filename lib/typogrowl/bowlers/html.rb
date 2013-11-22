# encoding: utf-8

require 'net/http'
require 'nokogiri'

require_relative '../core/bowler'
require_relative '../bowlers/htmldoc'

module Typogrowl
  # Markup processor for Html output.
  # 
  # This class produces HTML from markup as Markdown does.
  class Html < Bowler
    # `:linewide` default handler
    # @param [Array] args the words, gained since last call to {#harvest}
    def • *args
      harvest __callee__, tagify(@mapping.get(:linewide, __callee__), {}, args)
    end
    
    # `:inplace` default handler
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Array] the array of words with trimmed `inplace` tag
    def ≡ *args
      tagify(@mapping.get(:inplace, __callee__), {}, args)
    end
    
    # `:flush` default handler
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Array] the array of words with prepended `flush` tag
    def ⏎ *args
      [opening(@mapping.get(:flush, __callee__)), args]
    end
    
    # `:flush` handler for horizontal rule; it differs from default
    # handler since orphans around must be handled as well.
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Nil] nil
    def —— *args
      harvest nil, orphan(args.join(SEPARATOR)) unless args.vacant?
      harvest __callee__, opening(@mapping.get(:flush, __callee__))
    end
    
    # `:block` default handler
    # @param [Array] args the words, gained since last call to {#harvest}
    # @param [String] param the text to be places on the same string as
    # opening tag
    # @return [Nil] nil
    def Λ param, *args
      harvest __callee__, 
              tagify(
                      @mapping.get(:block, __callee__), 
                      {:class=>param.strip}, 
                      args.join(SEPARATOR).hsub(String::HTML_ENTITIES)
                    )
    end

    # `:block` handler for comment (required because comments are
    # formatted in HTML in some specific way.)
    # @param [String] param the text to be places on the same string as opening tag
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Nil] nil
    def ✍ param, *args
      harvest __callee__, 
        "<!-- [#{param.strip}]#{args.join(SEPARATOR)} -->"      
    end

    # `:inline` handler for comment (required because comments are
    # formatted in HTML in some specific way.)
    # @param [String] param the text to be places on the same string as opening tag
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Nil] nil
    def ✎ *args
      harvest __callee__, "<!-- #{args.join(SEPARATOR)} -->" 
    end

    # `:magnet` default handler
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Array] the array of words with trimmed `magnet` tag
    def ☎ *args
      param, *rest = args.flatten
      [tagify(@mapping.get(:magnet, __callee__), {}, param.to_s.prepend("#{__callee__}#{String::NBSP}")), rest]
    end
    
    # `:linewide` handler for data lists (required since data list items
    # consist of two tags: `dt` and `dd`.)
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Nil] nil
    def ▶ *args
      dt, dd = args.join(SEPARATOR).split(/\s*—\s*/)
      harvest __callee__, "#{tagify :dt, {}, dt}#{tagify :dd, {}, dd}"
    end
    # Alias for {#▶}, according to YAML rules specifies additional 
    # class for the data list `<dl>` tag behind (`dl-horizontal`.)
    alias_method :▷, :▶
    
    # `:handshake` default handler
    # @param [String] from packed as string operand “before”
    # @param [String] from packed as string operand “after”
    # @return 
    def ∈ *args
      from, till, *rest = args.flatten
      tag = @mapping.get(:handshake, __callee__)
      tag = tag[:tag] if Hash === tag
      [tagify(tag, {}, "#{from}#{__callee__}#{till}".gsub(String::WIDESPACE, ' ')), rest]
    end
    alias_method :⊂, :∈
    
    # Handler for anchors.
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Array] the array of words with trimmed `a` tag
    def ⚓ *args
      href, *title = args.flatten
      case get_href_content(href)
      when :img 
        opening :img, { :src => href, :alt => title.join(SEPARATOR) }
      else 
        tagify @mapping.get(:inplace, __callee__), {:href => href}, title
      end
    end

    # Handler for Youtube video
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Nil] nil
    def ✇ *args
      id, *rest = args.flatten
      harvest nil, orphan(rest.join(SEPARATOR)) unless rest.vacant?
      harvest __callee__, "<iframe width='560' height='315' src='http://www.youtube.com/embed/#{id}' 
               frameborder='0' allowfullscreen></iframe>"
    end
    
    # Handler for standalone pictures and
    # @todo Make it to understand quotes when there is a plain HTML on the other side
    # 
    # @param 
    # @return [Nil] nil
    def ⚘ *args
      href, *title = args.flatten
      harvest __callee__, "<figure><img src='#{href}'><figcaption><p>#{title.join(SEPARATOR)}</p></figcaption></figure>"
    end
    
    # Handler for abbrs.
    # @param [Array] args the words, gained since last call to {#harvest}
    # @return [Array] the array of words with trimmed `abbr` tag
    def † *args
      term, *title = args.flatten
      tagify @mapping.get(:inplace, __callee__), {:title => title.join(SEPARATOR)}, term
    end

    def unparse_and_roll str
      html_doc = HtmlDoc.new @mapping
      parser = Nokogiri::HTML::SAX::Parser.new(html_doc)
      parser.parse(str)
      puts '='*40
      puts html_doc.tg
      puts '='*40
      html_doc.tg
    end

    # Constructor merges rules from the file given, extends class definition
    # with methods not defined explicitly, but specified in rules. E.g. whether
    # the rules file contains `:≈ : :em` definition for emphasis markup under
    # the `:inplace` section, the class will be extended with:
    # 
    #     alias_method :≈, :≡
    #     
    # where the `:≡` is the default processing method for `:inplace` tags.
    # 
    # Also there is `:custom` section processing (currently simply by
    # substituting items from rules within their values.)
    # 
    # @param [String] file to read rules to merge from
    def initialize file = nil
      super
      merge_rules file if file
    end
    
  private
    # Constructs opening html tag for the input given.
    # 
    # To construct `abbr` tag with `title` _Title_ and class _default_:
    # 
    #     opening :abbr, { :title=>'Title', :class=>'default' }
    # 
    # @param [String] tag to produce opening tag string from.
    # @param [Hash] params to be put into opening tag as attributes. 
    # @return [String] opening tag for the input given.
    def opening tag, params={}
      tag, *clazz = tag.to_s.split('†')
      clazz = clazz.vacant? ? nil : " class='#{clazz.join(' ').gsub(/_/, '-')}'"
      attrs = params.inject("") { |m, k| m.prepend " #{k.first}='#{k.last}'" }
      "<#{tag}#{clazz}#{attrs}>"
    end
    
    # Constructs closing html tag for the input given.
    # 
    # @param [String] tag to produce closing tag string from.
    # @return [String] opening tag for the input given.
    def closing tag
      "</#{tag.to_s.split('†').first}>"
    end

    # Constructs valid tag for the input given, concatenating
    # opening and closing tags around the text passed in `args`.
    # 
    # @param [String] tag to produce html tag string from.
    # @param [Hash] params to be put into opening tag as attributes. 
    # @param [Array] args the words, to be tagged around. 
    # @return [String] opening tag for the input given.
    def tagify tag, params, *args
      args = args.join(SEPARATOR) if Array === args
      "#{opening tag, params}#{args.strip}#{closing tag}"
    end

    # Produces html paragraph tag (`<p>`) with class `dropcap`.
    # @see Typogrowl::Bowler#orphan
    # @param str the words, to be put in paragraph tag.
    # @return [String] tagged words.
    def orphan str
      tagify :p, {:class => 'dropcap'}, str.to_s.strip
    end

    # Computes the level of the `:linewide` element by counting
    # preceeding non-breakable spaces. For instance, nested lists
    # are produced by appending `"\u{00A0}"` to the line item
    # DSL tag: 
    # 
    #     li = "• li1 \u{00A0}• nested 1 \u{00A0}• nested 2 • li2"
    #     
    # @param [Symbol|String] oper the DSL symbol to get the level information for.
    # @return [Integer] the level requested. 
    #
    def level oper
      return 0 if oper.nil?
      oper = oper.to_s
      (0..oper.length-1).each { |i| break i if oper[i] != String::NBSP }
    end

    # @see Typogrowl::Bowler#harvest
    # 
    # Additionally it checks if there was a `:linewide` item, requiring
    # surrounding html element (like `<ul>` aroung several `<li>`s.)
    # 
    # @param [Symbol] callee of method
    # @param [String] str to be harvested
    def harvest callee, str
      unless callee == @callee
        prv = @mapping.get(:enclosures, @callee)
        nxt = @mapping.get(:enclosures, callee)
        if prv && (!callee || level(callee) <= level(@callee))
          @yielded.each { |s| s.gsub!(/#{level(@callee).␚ify}/, closing(prv)) }
          @yielded.last.sub!(/\A/, opening(prv))
        end
        str += closing(nxt) \
          if nxt && (!@callee || level(callee) >= level(@callee))
        # if there was a jump down layers, e.g. we encountered second
        #    level while being on zeroth
        (level(callee) - 1).downto(level(@callee)) { |i|
          logger.debug "Jump down levels #{level(@callee)} ⇒ #{level(callee)} Context: #{str}"
          str += i.␚ify
        } unless nested_base(callee) == nested_base(@callee)
        # if there was a jump up layers, e.g. we encountered second
        #    level while being on fifth
        (level(@callee) - 1).downto(level(callee)) { |i|
          logger.debug "Jump up levels #{level(@callee)} ⇒ #{level(callee)}. Context: #{str}"
          @yielded.each { |s|
            logger.warn "Control characters (level=#{i}) left in the output. Trying to fix by removal." \
              if s.gsub!(/#{i.␚ify}/, '')
          }
        } unless nested_base(callee) == nested_base(@callee)
        @callee = callee
      end
      super callee, str
    end
    
    # @see Typogrowl::Bowler#defreeze
    # 
    # Additionally it checks if tag is a `:block` tag and 
    # substitutes all the carriage returns (`$/`) with special symbol
    # {String::CARRIAGE_RETURN} to prevent format damage.
    # 
    # @param [String] str to be defreezed
    def defreeze str
      str = super str
      @mapping.block.each { |tag, htmltag| 
        str.gsub!(/(#{tag})(.*?)$(.*?)(#{tag}|\Z)/m) { |m|
          "#{$1}('#{$2}', '#{$3.carriage}')"
        }
      }
      str
    end

    # @see Typogrowl::Bowler#method_missing
    #
    # Lazy extends class with methods for nested `:linewide`s and 
    # handles calls for words starting with elements from `:inplace` section.
    # The latter is necessary since the common usage of markup is:
    # 
    #     This text is ≡bold≡.
    #     
    # Not
    # 
    #     #             ⇓ note the space here
    #     This text is ≡ bold.
    # 
    # Hence we cannot simply declare the DSL for it, we need to handle 
    # calls to all the _methods_, starting with those symbols.
    # 
    # @param [Symbol] method as specified by caller (`method_missing`.)
    # @param [Array] args as specified by caller (`method_missing`.)
    # @param [Proc] block as specified by caller (`method_missing`.)
    # 
    # @return [Array] the array of words
    def special_handler method, *args, &block
      # Sublevel markers, e.g. “ •” is level 2 line-item
      if level(method) > 0 && @mapping.dup_spice(orig = nested_base(method), method)
        # create alias for nested
        Html.class_eval %Q{
          alias_method :#{method.to_s.bowl}, :#{orig}
        }
        # after all, we need to process this nested operator
        return send(method, args)
      else
        # Inplace tags, like “≡” for ≡bold decoration≡ 
        # FIXME Not efficient!
        @mapping.inplace.each { |tag, htmltag|
          tag = tag.to_s.bowl
          if method.to_s.start_with? tag
              return [method, args].join(SEPARATOR).gsub(/#{tag}(.*?)(#{tag}|\Z)/) { |m|
              send(tag, eval($1)).bowl
            }.split(SEPARATOR)
          end
        }
      end
      [method, args].flatten
    end

    # Determines content of remote link by href.
    # @param [String] href link to remote resource
    # @return [Symbol] content type (`:img` or `:text` currently)
    def get_href_content href
      uri = URI(href.to_s.unbowl)
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.open_timeout = 3

        request = Net::HTTP::Head.new uri
        response = http.request request
        case response.to_hash["content-type"].first
        when /image/ then return :img
        when /text/ then return :text
        end
      end
      :unknown
    rescue
      logger.warn "Unable to determine link type: no internet connection. Reverting to default."
      :unknown
    end

    # Determines nested method’s base (e.g. “•” for [second level] “  •”)
    # @param [Symbol] nested the name of the nested method
    # @return [Symbol] the base (original) method name
    def nested_base nested
      nested ? nested.to_s[level(nested), nested.length].to_sym : nil
    end
  end
end
