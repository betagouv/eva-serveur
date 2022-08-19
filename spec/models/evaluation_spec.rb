# frozen_string_literal: true

require 'rails_helper'

describe Evaluation do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :debutee_le }
  it { is_expected.to belong_to :campagne }
  it { is_expected.to have_one :condition_passation }

  describe 'verifie la génération du bénéficiaire' do
    let!(:evaluation) { create :evaluation, nom: 'NOM' }

    context "quand nous n'avons pas de bénéficiaire" do
      it 'génére un bénéficiaire du même nom' do
        evaluation.ajout_du_beneficiaire_avec_nom!
        expect(evaluation.beneficiaire.nom).to eq('NOM')
      end
    end

    context 'quand nous avons déjà un bénéficiaire' do
      it 'ne change pas le nom du bénéficiaire' do
        evaluation.ajout_du_beneficiaire_avec_nom!
        evaluation.nom = 'nouveau NOM'
        evaluation.ajout_du_beneficiaire_avec_nom!
        expect(evaluation.beneficiaire.nom).to eq('NOM')
      end
    end
  end
end
