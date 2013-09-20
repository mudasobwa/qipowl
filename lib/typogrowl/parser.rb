# encoding: utf-8

require 'uri'
require 'net/http'

module Typogrowl
  module Parser
    class Preliminary
      attr_reader :text, :out
      
      def initialize text
        @text = @out = text
        parse_brackets(@out)
        parse_section(@out, :all_sufficient)
        parse_control(@out)
        parse_section(@out, :till_space)
        parse_links(@out)
        parse_section(@out, :surroundings, :sprawling, :nested, :till_eol, :block)
      end
      
      private
      #################################################################
      # Parses section from the configuration `yaml` file.
      # It walks through `tags` and for each looks up the 
      # regexp in the same section with the same name. If no such
      # regexp is provided, it uses the `default` regexp from 
      # that section. Than it substs placeholder(s) with the
      # tag, retrieves all the captures and produces output as:
      #     ≡( ' TEXT ' )
      # for strongs, or:
      #     ¹( ' Wikipedia ', ' ⚓('http://wikipedia.org') ' )
      # for links (Wikipedia¹http://wikipedia.org)
      #################################################################     
      def parse_section str, *sections
        sections.each { |section|
          section = section.to_sym
          ph = Tags.tag(:placeholder, :control)
          Tags.tags(section).values.flatten.each { |tag|
            re = (Tags.regexp(Tags.tag_key(tag, section), section) || 
                  Tags.regexp(:default, section)).gsub(/#{ph}/, tag)
            str.gsub!(/#{re}/) { |m|
              dsl = $~[:dsl] rescue nil
              captures = $~.captures
              operator = Tags.operator(Tags.tag_key(tag, section), section)
              if operator.nil?
                operator = dsl
                captures -= [operator]
                operator = operator.strip.gsub(/ /, Tags.tag(:nbsp, :control))
                params = captures.empty? ? '' : " ' #{captures.join( ' \', \' ' )} ' "
              else
                params = " ' #{m} ' "
              end
              params.gsub!(/#{Tags.regexp(:cleanup, section)}/, ' ') \
                if Tags.regexp(:cleanup, section)
              "#{operator}(#{params})"
            }
          }
        }
      end
      #################################################################
      # All the brackets are temporarily substituted to infernals
      def parse_brackets str
        str.gsub!(/\(/, Tags.tag(:bracket_open, :control))
        str.gsub!(/\)/, Tags.tag(:bracket_close, :control))
        str.gsub!(/\n(?=\p{Alnum})/, ' ')
        str
      end
      #################################################################
      # — Bernard Show, http://youtu.be/Sf9867dD
      # must be: 
      # Bernard Show¹http://youtu.be/Sf9867dD
      def parse_control str
        re = /#{Tags.regexp(:links, :control)}/
        str.gsub!(re) { |m|
          title, href = $~.captures
          href.gsub(URI.regexp, '').strip.empty? ? 
            "#{title.gsub(/ /, ' ')}¹#{href}\n\n" : m
        }
      end
      #################################################################
      # @return [String] or [nil] if nothing was modified (exactly as
      # `gsub!` does
      def parse_links str
        str.gsub!(URI::regexp) { |m|
          "#{link_type m}('#{m}')"
        }
      end
      
      def link_type link
        # Known href-pattern?
        Tags.regexps(:internal).each { |k, v|
          v.each { |re|
            return Tags.tag(k, :internal) if /#{re}/ =~ link
          }
        }
        
        # Let’s determine type of content then
        uri = URI(link)
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.open_timeout = 3

          request = Net::HTTP::Head.new uri
          response = http.request request
          Tags.tag(
            case response.to_hash["content-type"].first
            when /image/ then 'img'
            when /text/  then 'link'
            else 'unknown'
            end
          )
        end
      rescue
        Tags.tag('error')
      end
    end
  end
end
