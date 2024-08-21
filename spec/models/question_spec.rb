# frozen_string_literal: true

require 'rails_helper'

describe Question, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }
  it { is_expected.to have_many(:transcriptions).dependent(:destroy) }
  it { is_expected.to accept_nested_attributes_for(:transcriptions).allow_destroy(true) }
  it { is_expected.to have_one_attached(:illustration) }

  describe '#restitue_reponse' do
    context "quand la question saisie n'a pas de choix" do
      let(:question) { create :question_saisie }

      it 'retourne la réponse' do
        expect(question.restitue_reponse('35')).to eq '35'
      end
    end

    context 'quand la question saisie a un choix' do
      let(:choix1) do
        create :choix,
               :bon,
               nom_technique: 'choix_1',
               intitule: 'intitule'
      end
      let(:question) { create :question_saisie, bonne_reponse: choix1 }

      it 'retourne la réponse' do
        expect(question.restitue_reponse('35')).to eq '35'
      end
    end

    context "quand la reponse est un des choix d'un qcm" do
      let(:choix1) do
        create :choix,
               :bon,
               nom_technique: 'choix_1',
               intitule: 'intitule'
      end
      let(:question) { create :question_qcm, choix: [choix1] }

      it "retourne l'intitulé de la réponse" do
        expect(question.reload.restitue_reponse('choix_1')).to eq 'intitule'
      end
    end
  end
end
