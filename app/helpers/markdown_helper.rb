# frozen_string_literal: true

module MarkdownHelper
  def md(contenu)
    return '' if contenu.nil?

    interprete_markdown_en_html(contenu)
  end

  private

  class EvaMarkdownRender < Redcarpet::Render::HTML
    def double_emphasis(quote)
      %(<strong class="fw-semi-bold">#{quote}</strong>)
    end
  end

  def interprete_markdown_en_html(contenu)
    markdown ||= Redcarpet::Markdown.new(EvaMarkdownRender, tables: true, hard_wrap: true)
    markdown.render(contenu).html_safe
  end
end
