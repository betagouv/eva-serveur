# frozen_string_literal: true

module MarkdownHelper
  def md(contenu)
    return '' if contenu.nil?

    interprete_markdown_en_html(contenu)
  end

  private

  def interprete_markdown_en_html(contenu)
    markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true)
    )
    markdown.render(contenu).html_safe
  end
end
