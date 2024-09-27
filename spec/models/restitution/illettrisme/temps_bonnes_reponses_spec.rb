# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::TempsBonnesReponses do
  let(:temps_bonnes_reponses_numeratie) do
    described_class.new.calcule(evenements_decores(evenements, :livraison), 'numeratie')
  end
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end
  let(:evenements_reponses) { [] }
  let(:bon_choix) { create :choix, :bon }
  let(:mauvais_choix) { create :choix, :mauvais }
  let(:question_numeratie) do
    create :question_qcm, metacompetence: :numeratie, choix: [bon_choix, mauvais_choix]
  end

  describe 'metrique temps de bonnes réponses' do
    context 'sans événement réponse' do
      it { expect(temps_bonnes_reponses_numeratie).to eq([]) }
    end

    context 'une bonne réponse' do
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_numeratie.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: question_numeratie.id,
                                               reponse: bon_choix.id },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22))
        ]
      end

      it { expect(temps_bonnes_reponses_numeratie).to eq([1]) }
    end

    context 'une mauvaise réponse' do
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_numeratie.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: question_numeratie.id,
                                               reponse: mauvais_choix.id },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22))
        ]
      end

      it { expect(temps_bonnes_reponses_numeratie).to eq([]) }
    end

    context 'ignore les autres compétences' do
      let(:bon_choix_ccf) { create :choix, :bon }
      let(:question_ccf) do
        create :question_qcm, metacompetence: :ccf, choix: [bon_choix_ccf]
      end
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_ccf.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: question_ccf.id,
                                               reponse: bon_choix_ccf.id },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22))
        ]
      end

      it { expect(temps_bonnes_reponses_numeratie).to eq([]) }
    end

    context 'ignore les questions sans réponses' do
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_numeratie.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21))
        ]
      end

      it { expect(temps_bonnes_reponses_numeratie).to eq([]) }
    end
  end
end
