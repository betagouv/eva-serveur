# frozen_string_literal: true

require 'rails_helper'

describe Question, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }
  it { is_expected.to accept_nested_attributes_for(:transcriptions).allow_destroy(true) }
  it { is_expected.to have_one_attached(:illustration) }
  it { is_expected.to have_one(:transcription_intitule).dependent(:destroy) }
  it { is_expected.to have_one(:transcription_modalite_reponse).dependent(:destroy) }
  it { is_expected.to have_one(:transcription_consigne).dependent(:destroy) }

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
      let(:question) { create :question_saisie, reponses: [choix1] }

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

  describe '#json_audio_fields' do
    let(:question) { create :question }
    let!(:transcription_consigne) do
      create :transcription, question_id: question.id, categorie: :consigne
    end

    context 'quand la question a des transcriptions audios' do
      context "quand l'intitulé est complet" do
        before do
          question.transcription_intitule.audio.attach(
            io: Rails.root.join('spec/support/alcoolique.mp3').open, filename: 'alcoolique.mp3'
          )
        end

        it "retourne l'url de l'audio de l'intitulé dans le champ audio_url" do
          expect(question.transcription_intitule.complete?).to be true
          expect(question.json_audio_fields['audio_url']).to eq(
            question.transcription_intitule.audio_url
          )
        end
      end

      context "quand l'intitulé est incomplet" do
        before do
          question.transcription_intitule.audio.attach(
            io: Rails.root.join('spec/support/alcoolique.mp3').open, filename: 'alcoolique.mp3'
          )
          question.transcription_intitule.update(ecrit: nil)
        end

        it "retourne l'url de l'audio de l'intitulé dans le champ intitule_audio" do
          expect(question.transcription_intitule.complete?).to be false
          expect(question.json_audio_fields['audio_url']).to be_nil
          expect(question.json_audio_fields['intitule_audio']).to eq(
            question.transcription_intitule.audio_url
          )
        end
      end

      context 'quand la modalité de réponse est complète' do
        let!(:modalite_reponse) do
          create :transcription, :avec_audio, question_id: question.id, categorie: :modalite_reponse
        end

        it "retourne l'url de l'audio de la modalité de réponse dans le champ intitule_audio" do
          expect(question.transcription_modalite_reponse.complete?).to be true
          expect(question.json_audio_fields['audio_url']).to eq(
            question.transcription_modalite_reponse.audio_url
          )
        end
      end

      context "quand la modalité de réponse est complète et l'intitulé incomplet" do
        let!(:modalite_reponse) do
          create :transcription, :avec_audio, question_id: question.id, categorie: :modalite_reponse
        end

        before do
          question.transcription_intitule.audio.attach(
            io: Rails.root.join('spec/support/alcoolique.mp3').open, filename: 'alcoolique.mp3'
          )
          question.transcription_intitule.update(ecrit: nil)
        end

        it do
          fields = question.json_audio_fields
          expect(fields['audio_url']).to eq(question.transcription_modalite_reponse.audio_url)
          expect(fields['intitule_audio']).to eq(question.transcription_intitule.audio_url)
        end
      end

      it "retourne l'audio de la consigne" do
        question.transcription_consigne.audio.attach(
          io: Rails.root.join('spec/support/alcoolique.mp3').open, filename: 'alcoolique.mp3'
        )
        expect(question.json_audio_fields['consigne_audio']).to eq(
          question.transcription_consigne.audio_url
        )
      end
    end
  end
end
