# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::AttentionVisuoSpaciale do
  let(:metrique_attention_visuo_spaciale) do
    described_class.new.calcule(evenements_decores(evenements, :securite), [])
  end

  describe '#attention_visuo_spatiale' do
    let(:danger_visuo_spatial) { EvenementSecurite::DANGER_VISUO_SPATIAL }

    context 'sans évenement: indéterminé' do
      let(:evenements) { [] }

      it { expect(metrique_attention_visuo_spaciale).to eq Competence::NIVEAU_INDETERMINE }
    end

    context "avec identification du danger sans avoir activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: danger_visuo_spatial }) ]
      end

      it { expect(metrique_attention_visuo_spaciale).to eq Competence::APTE }
    end

    context "avec identification du danger après avoir activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage, date: 3.minutes.ago),
         build(:activation_aide, date: 2.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: danger_visuo_spatial },
               date: 1.minute.ago) ]
      end

      it { expect(metrique_attention_visuo_spaciale).to eq Competence::APTE_AVEC_AIDE }
    end

    context "avec identification du danger avant avoir activé l'aide" do
      let(:evenements) do
        [ build(:evenement_demarrage, date: 3.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: danger_visuo_spatial },
               date: 2.minutes.ago),
         build(:activation_aide, date: 1.minute.ago) ]
      end

      it { expect(metrique_attention_visuo_spaciale).to eq Competence::APTE }
    end
  end
end
