# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Competence::Base do
  it 'niveau rennvoie une exception NotImplementedError' do
    expect do
      described_class.new(nil).niveau
    end.to raise_error(NotImplementedError)
  end
end
