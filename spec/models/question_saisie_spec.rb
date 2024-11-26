# frozen_string_literal: true

require 'rails_helper'

describe QuestionSaisie, type: :model do
  it { is_expected.to have_many(:reponses).with_foreign_key(:question_id) }

  describe '#as_json' do
    let(:question_saisie) do
      create(:question_saisie,
             transcription_ecrit: 'Mon Intitulé',
             reponse_placeholder: 'écrivez ici',
             type_saisie: 'texte',
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ))
    end
    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_saisie.id,
                                          categorie: :modalite_reponse)
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_saisie.id) }
    let!(:reponse2) { create(:choix, :bon, question_id: question_saisie.id) }
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
                                          placeholder reponses texte_a_trous consigne_audio
                                          demarrage_audio_modalite_reponse])
      expect(json['type']).to eql('saisie')
      expect(json['sous_type']).to eql('texte')
      expect(json['placeholder']).to eql('écrivez ici')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['reponses'][0]['intitule']).to eql(reponse.intitule)
      expect(json['reponses'][0]['type_choix']).to eql('bon')
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
    end

    it "retourne l'illustration" do
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_saisie.illustration
                                          ))
    end

    context "quand il n'y a pas de réponse" do
      it 'ne retourne pas de reponse' do
        reponse.destroy
        expect(json['reponse']).to be_nil
      end
    end

    describe '#bonnes_reponses' do
      it 'retourne les bonnes réponses' do
        expect(question_saisie.bonnes_reponses).to eql('bon choix | bon choix')
      end
    end
  end
end
