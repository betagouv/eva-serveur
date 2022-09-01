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
    customise_rendu_gras(markdown.render(contenu)).html_safe
  end

  def customise_rendu_gras(html)
    html.gsub('<strong>', '<strong class="fw-semi-bold">')
  end
end
