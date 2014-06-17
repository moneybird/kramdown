# -*- coding: utf-8 -*-

require 'kramdown/parser/markdown'

module Kramdown

  module Parser

    class MarkdownLite < Markdown

      # Array with all the parsing methods that should be removed from the standard markdown parser.
      EXTENDED = [:autolink, :blank_line, :blockquote, :horizontal_rule, :line_break, :list, :paragraph, :table]

      def initialize(source, options)
        super
        @block_parsers.delete_if {|i| EXTENDED.include?(i)}
        @span_parsers.delete_if {|i| EXTENDED.include?(i)}
      end

    end

  end

end
