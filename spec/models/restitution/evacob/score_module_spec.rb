# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Evacob::ScoreModule do
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end

  describe 'metrique score_orientation' do
    let(:metrique_score_reponse_orientation) do
      described_class.new.calcule(evenements_decores(evenements, :evacob), :orientation)
    end
    let(:question_lodi1) { 'LOdi1' }
    let(:question_lodi2) { 'LOdi2' }
    let(:question_hpar1) { 'HPar1' }

    context 'somme les scores des réponses du module' do
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_lodi1 }),
          build(:evenement_reponse, donnees: { question: question_lodi1, score: 1 }),
          build(:evenement_affichage_question_qcm, donnees: { question: question_lodi2 }),
          build(:evenement_reponse, donnees: { question: question_lodi2, score: 2.5 }),
          build(:evenement_reponse, donnees: { question: 'autre_question', score: 100 }),
          build(:evenement, donnees: { score: 100 })
        ]
      end

      it { expect(metrique_score_reponse_orientation).to eq(3.5) }
    end

    context 'avec une réponse du module sans score' do
      let(:evenements_reponses) do
        [build(:evenement_reponse, donnees: { question: question_lodi1 })]
      end

      it { expect(metrique_score_reponse_orientation).to eq(0) }
    end

    context 'sans réponse du module orientation' do
      let(:reponse_parcours_haut) do
        build(:evenement_reponse, donnees: { question: question_hpar1 })
      end
      let(:evenements_reponses) { [reponse_parcours_haut] }

      it { expect(metrique_score_reponse_orientation).to eq(nil) }
    end

    context 'sans réponse' do
      let(:evenements_reponses) { [] }

      it { expect(metrique_score_reponse_orientation).to eq(nil) }
    end
  end

  describe 'metrique score_numeratie' do
    let(:metrique_score_reponse_numeratie) do
      described_class.new.calcule(evenements_decores(evenements, :place_du_marche), :N1,
                                  avec_rattrapage: true)
    end
    let(:question_initiale1) { 'N1Pes1' }
    let(:question_rattrapage1) { 'N1Res1' }
    let(:question_initiale2) { 'N1Pes2' }
    let(:question_rattrapage2) { 'N1Res2' }

    context 'sans réponses au rattapage' do
      let(:evenements_reponses) do
        [build(:evenement_reponse, donnees: { question: question_initiale1, score: 1 })]
      end

      it do
        expect(metrique_score_reponse_numeratie).to eq(1)
      end
    end

    context 'avec réponses au rattapage' do
      context 'lorsque le score total du rattrapage est meilleur' do
        let(:evenements_reponses) do
          [
            build(:evenement_reponse, donnees: { question: question_initiale1, score: 1 }),
            build(:evenement_reponse, donnees: { question: question_initiale2, score: 0 }),
            build(:evenement_reponse, donnees: { question: question_rattrapage1, score: 1 }),
            build(:evenement_reponse, donnees: { question: question_rattrapage2, score: 1 })
          ]
        end

        it do
          expect(metrique_score_reponse_numeratie).to eq(2)
        end
      end

      context 'lorsque le score total initial est meilleur' do
        let(:evenements_reponses) do
          [
            build(:evenement_reponse, donnees: { question: question_initiale1, score: 1 }),
            build(:evenement_reponse, donnees: { question: question_initiale2, score: 1 }),
            build(:evenement_reponse, donnees: { question: question_rattrapage1, score: 0 }),
            build(:evenement_reponse, donnees: { question: question_rattrapage2, score: 1 })
          ]
        end

        it do
          expect(metrique_score_reponse_numeratie).to eq(2)
        end
      end
    end
  end

  context 'sans evenements réponses' do
    let(:metrique_score) do
      described_class.new.calcule(evenements_decores(evenements, :place_du_marche), :N1)
    end
    let(:evenements_reponses) { [] }

    it 'retourne nil' do
      expect(metrique_score).to eq(nil)
    end
  end
end
