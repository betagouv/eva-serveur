require 'rails_helper'

describe Restitution::Illettrisme::NombreReponses do
  describe 'livraison' do
    let(:metrique_nombre_reponses_ccf) do
      described_class.new.calcule(evenements_decores(evenements, :livraison), 'ccf')
    end
    let(:evenements) { [] }
    let(:choix_ccf) { create :choix, :mauvais }
    let(:question_ccf) do
      create :question_qcm, :metacompetence_ccf, choix: [ choix_ccf ]
    end

    describe 'metrique nombre_reponses' do
      context "pas d'événements réponse" do
        it { expect(metrique_nombre_reponses_ccf).to eq(0) }
      end

      context 'avec une réponse' do
        let(:evenements) do
          [ build(:evenement_reponse,
                 donnees: { question: question_ccf.id, reponse: choix_ccf.id }) ]
        end

        it { expect(metrique_nombre_reponses_ccf).to eq(1) }
      end

      context 'ignore les événements non réponse' do
        let(:question_ccf) { create :question_qcm, :metacompetence_ccf }
        let(:evenements) do
          [
            build(:evenement_demarrage),
            build(:evenement_affichage_question_qcm,
                  donnees: { question: question_ccf.id, metacompetence: :ccf })
          ]
        end

        it { expect(metrique_nombre_reponses_ccf).to eq(0) }
      end

      context 'ignore les réponses des autres metacompetences' do
        let(:question_numeratie) { create :question_qcm, nom_technique: 'numeratie_division' }
        let(:choix_numeratie) { create :choix, :bon, question_id: question_numeratie.id }
        let(:evenements) do
          [ build(:evenement_reponse,
                 donnees: { question: question_numeratie.id, reponse: choix_numeratie.id }) ]
        end

        it { expect(metrique_nombre_reponses_ccf).to eq(0) }
      end
    end
  end

  describe 'objets_trouves' do
    let(:metrique_nombre_reponses_ccf) do
      described_class.new.calcule(evenements_decores(evenements, :objets_trouves), 'ccf')
    end
    let(:evenements) { [] }

    describe 'metrique nombre_reponses' do
      context "pas d'événements réponse" do
        it { expect(metrique_nombre_reponses_ccf).to eq(0) }
      end

      context 'avec une réponse' do
        let(:evenements) do
          [ build(:evenement_reponse, donnees: { reponse: '5', metacompetence: :ccf }) ]
        end

        it { expect(metrique_nombre_reponses_ccf).to eq(1) }
      end

      context 'ignore les événements non réponse' do
        let(:evenements) { [] }
        let(:evenements) do
          [ build(:evenement_demarrage),
           build(:evenement_affichage_question_qcm,
                 donnees: { question: :fin1, metacompetence: :ccf }) ]
        end

        it { expect(metrique_nombre_reponses_ccf).to eq(0) }
      end
    end
  end
end
