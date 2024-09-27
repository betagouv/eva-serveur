# frozen_string_literal: true

require 'rails_helper'

describe EvaluationHelper do
  describe '#niveau_bas?' do
    let(:profil1) { Competence::PROFILS_BAS.first }
    let(:profil_autre) { :profil_autre }

    it 'Retourne true si le profil renseigné est un niveau bas' do
      expect(niveau_bas?(:profil1)).to be true
    end

    it "Retourne false si le profil renseigné n'est pas un niveau bas" do
      expect(niveau_bas?(:profil_autre)).to be false
    end
  end
end
