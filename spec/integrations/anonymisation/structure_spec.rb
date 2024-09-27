# frozen_string_literal: true

require 'rails_helper'

describe Anonymisation::Structure, type: :integration do
  context 'avec une structure complete' do
    let(:structure) do
      create :structure_locale, anonymise_le: nil,
                                code_postal: '45300',
                                nom: 'Mission locale Pithiviers'
    end

    it 'anonymise une structure' do
      described_class.new(structure).anonymise

      structure.reload
      expect(structure.anonymise_le).not_to be_nil
      expect(structure.code_postal).to eql('45300')
      expect(structure.nom).not_to eq 'Mission locale Pithiviers'
    end
  end

  context 'avec une structure sans code postal' do
    let(:structure) do
      create :structure_locale, anonymise_le: nil,
                                nom: 'Mission locale Pithiviers'
    end

    before do
      structure.code_postal = nil
      structure.save(validate: false)
    end

    it 'anonymise une structure' do
      described_class.new(structure).anonymise

      structure.reload
      expect(structure.code_postal).to eql('non_communique')
    end
  end
end
