# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionSaisie, type: :model do
  it { is_expected.to have_one(:bonne_reponse).with_foreign_key(:question_id) }

  describe '#as_json' do
    let(:question_saisie) do
      create(:question_saisie,
             transcription_ecrit: 'Mon Intitulé',
             reponse_placeholder: 'écrivez ici',
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ))
    end
    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_saisie.id,
                                          categorie: :modalite_reponse)
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_saisie.id) }
    let(:json) { question_saisie.as_json }

    before do
      Transcription.find_by(categorie: :intitule, question_id: question_saisie.id)
                   .update(audio: Rack::Test::UploadedFile.new(
                     Rails.root.join('spec/support/alcoolique.mp3')
                   ))
    end

    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique suffix_reponse
                                          description illustration modalite_reponse type sous_type
                                          placeholder reponse])
      expect(json['type']).to eql('saisie')
      expect(json['sous_type']).to eql('redaction')
      expect(json['placeholder']).to eql('écrivez ici')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['reponse']['textes']).to eql(reponse.intitule)
      expect(json['reponse']['bonneReponse']).to be(true)
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
    end

    it "retourne l'illustration" do
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_saisie.illustration
                                          ))
    end

    context "quand il n'y a pas d'intitulé écrit" do
      before do
        Transcription.find_by(categorie: :intitule,
                              question_id: question_saisie.id).update(ecrit: '')
        json
      end

      it "retourne l'audio de la consigne en audio principal" do
        expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                           modalite.audio
                                         ))
      end

      it "retourne l'audio de l'intitulé en audio secondaire" do
        expect(json['intitule_audio']).to eql(Rails.application.routes.url_helpers.url_for(
                                                question_saisie.transcriptions.first.audio
                                              ))
      end
    end

    context 'quand il y a un intitulé écrit' do
      it "retourne l'audio de l'intitulé en audio principal" do
        json
        expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                           question_saisie.transcriptions.first.audio
                                         ))
      end
    end
  end
end
