# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::AlertInterpreterResultatsComponent, type: :component do
  it do
    expect(
      render_inline(described_class.new).to_html
    ).to include(
      'Interpréter les résultats'
    )
  end
end
