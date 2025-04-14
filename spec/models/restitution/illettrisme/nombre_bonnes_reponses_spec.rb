# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::NombreBonnesReponses do
  let(:metrique_nombre_bonnes_reponses_numeratie) do
    described_class.new.calcule(evenements_decores(evenements, :livraison), 'numeratie')
  end
  let(:evenements) do
    [ build(:evenement_demarrage) ] + evenements_reponses
  end
  let(:evenements_reponses) { [] }
  let(:bon_choix_numeratie) { create :choix, :bon }
  let(:question_numeratie) do
    nom_technique = QuestionData.find_by(metacompetence: 'numeratie').nom_technique
    create :question_qcm, nom_technique: nom_technique, choix: [ bon_choix_numeratie ]
  end

  describe 'metrique nombre_bonnes_reponses' do
    context "pas d'événements réponse" do
      it { expect(metrique_nombre_bonnes_reponses_numeratie).to eq(0) }
    end

    context 'avec une bonne réponse' do
      let(:evenements_reponses) do
        [ build(:evenement_reponse,
               donnees: { question: question_numeratie.id, reponse: bon_choix_numeratie.id }) ]
      end

      it { expect(metrique_nombre_bonnes_reponses_numeratie).to eq(1) }
    end

    context 'avec des réponses autres que bonnes' do
      let(:choix_mauvais) do
        create :choix, :mauvais, question_id: question_numeratie.id
      end
      let(:choix_abstention) do
        create :choix, :abstention, question_id: question_numeratie.id
      end
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
                donnees: { question: question_numeratie.id, reponse: choix_mauvais.id }),
          build(:evenement_reponse,
                donnees: { question: question_numeratie.id, reponse: choix_abstention.id })
        ]
      end

      it { expect(metrique_nombre_bonnes_reponses_numeratie).to eq(0) }
    end

    context 'ignore les bonnes réponses des autres metacompetences' do
      let(:question_ccf) { create :question_qcm, :metacompetence_ccf }
      let(:bon_choix_ccf) { create :choix, :bon, question_id: question_ccf.id }
      let(:evenements_reponses) do
        [ build(:evenement_reponse,
               donnees: { question: question_ccf.id, reponse: bon_choix_ccf.id }) ]
      end

      it { expect(metrique_nombre_bonnes_reponses_numeratie).to eq(0) }
    end
  end
end
