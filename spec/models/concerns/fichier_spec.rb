# frozen_string_literal: true

require 'rails_helper'

describe Fichier do
  let(:test_class) do
    Class.new do
      include Fichier
    end
  end

  describe '#nom_fichier_horodate' do
    it 'genere un nom de fichier horodaté' do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        expect(test_class.new.nom_fichier_horodate('titre', 'extention'))
          .to eq('20250228010203-titre.extention')
      end
    end
  end

  describe '#nom_fichier_date' do
    it 'genere un nom de fichier date' do
      expect(test_class.new.nom_fichier_date(Date.new(2025, 2, 28), 'titre', 'extention'))
        .to eq('20250228-titre.extention')
    end
  end
end
