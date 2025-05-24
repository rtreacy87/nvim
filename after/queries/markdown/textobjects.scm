; extends

; Markdown-specific textobjects
; These provide alternatives to @block.outer which doesn't exist in markdown

; Code blocks (fenced and indented)
(fenced_code_block) @block.outer
(fenced_code_block
  (code_fence_content) @block.inner)

(indented_code_block) @block.outer

; List items as blocks
(list_item) @block.outer
(list_item
  (paragraph) @block.inner)

; Sections (content between headings)
(section) @section.outer
(section
  (paragraph) @section.inner)

; Headings
(atx_heading) @heading.outer
(atx_heading
  (atx_h1_marker)? @_start
  (atx_h2_marker)? @_start
  (atx_h3_marker)? @_start
  (atx_h4_marker)? @_start
  (atx_h5_marker)? @_start
  (atx_h6_marker)? @_start
  (inline) @heading.inner)

; Paragraphs
(paragraph) @paragraph.outer
(paragraph) @paragraph.inner

; Links
(link) @link.outer
(link
  (link_text) @link.inner)

; Emphasis
(emphasis) @emphasis.outer
(emphasis) @emphasis.inner

(strong_emphasis) @emphasis.outer
(strong_emphasis) @emphasis.inner

; Quotes
(block_quote) @quote.outer
(block_quote
  (paragraph) @quote.inner)

; Tables
(pipe_table) @table.outer
(pipe_table_row) @table.inner

; HTML blocks (if present)
(html_block) @block.outer
