# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2009-2014 Thomas Leitner <t_leitner@gmx.at>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#

require 'kramdown/parser/kramdown'

module Kramdown

  module Parser

    # Used for parsing a document in Markdown format.
    #
    # This parser is based on the kramdown parser and removes the parser methods for the additional
    # non-Markdown features. However, since some things are handled differently by the kramdown
    # parser methods (like deciding when a list item contains just text), this parser differs from
    # real Markdown parsers in some respects.
    #
    # Note, though, that the parser basically fails just one of the Markdown test cases (some others
    # also fail but those failures are negligible).
    class Markdown < Kramdown

      # Array with all the parsing methods that should be removed from the standard kramdown parser.
      EXTENDED = [:codeblock_fenced, :definition_list, :footnote_definition, :abbrev_definition, :block_math,
                  :block_extensions,
                  :footnote_marker, :inline_math, :span_extensions,
                  :codeblock, :autolink, :link, :link_definition, :setext_header, :atx_header, :line_break]

      def initialize(source, options) # :nodoc:
        super
        @block_parsers.delete_if {|i| EXTENDED.include?(i)}
        @span_parsers.delete_if {|i| EXTENDED.include?(i)}
      end

      def parse
        super
        add_hard_line_breaks(@root) if @options[:hard_wrap]
      end

      def add_hard_line_breaks(element)
        element.children.map! do |child|
          if child.type == :text && child.value =~ /\n/
            children = []
            lines = child.value.split(/\n(?=.)/)
            lines.each_with_index do |line, index|
              children << Element.new(:text, (index > 0 ? "\n#{line}" : line))
              children << Element.new(:br) if line =~ /\n/ and index < lines.size - 1
              children << Element.new(:br) if index < lines.size - 1
            end
            children
          elsif child.type == :html_element
            child
          else
            add_hard_line_breaks(child)
            child
          end
        end.flatten!
      end

      # :stopdoc:

      BLOCK_BOUNDARY = /#{BLANK_LINE}|#{EOB_MARKER}|\Z/
      LAZY_END = /#{BLANK_LINE}|#{EOB_MARKER}|^#{OPT_SPACE}#{LAZY_END_HTML_STOP}|^#{OPT_SPACE}#{LAZY_END_HTML_START}|\Z/
      CODEBLOCK_MATCH = /(?:#{BLANK_LINE}?(?:#{INDENT}[ \t]*\S.*\n)+)*/
      PARAGRAPH_END = LAZY_END

      IAL_RAND_CHARS = (('a'..'z').to_a + ('0'..'9').to_a)
      IAL_RAND_STRING = (1..20).collect {|a| IAL_RAND_CHARS[rand(IAL_RAND_CHARS.size)]}.join
      LIST_ITEM_IAL = /^\s*(#{IAL_RAND_STRING})?\s*\n/
      IAL_SPAN_START = LIST_ITEM_IAL

      # :startdoc:

    end

  end

end
