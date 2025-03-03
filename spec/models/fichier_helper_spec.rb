# frozen_string_literal: true

require 'rails_helper'

describe FichierHelper do
  describe '#nom_fichier_horodate' do
    it 'genere un nom de fichier horodaté' do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        expect(described_class.nom_fichier_horodate('titre', 'extention'))
          .to eq('20250228010203-titre.extention')
      end
    end
  end
end
