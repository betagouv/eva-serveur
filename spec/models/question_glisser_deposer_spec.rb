# frozen_string_literal: true

require 'rails_helper'

describe QuestionGlisserDeposer, type: :model do
  it { is_expected.to have_many(:reponses).with_foreign_key(:question_id) }

  describe '#as_json' do
    let(:question) do
      create(:question_glisser_deposer,
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ))
    end
    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question.id,
                                          categorie: :modalite_reponse)
    end
    let!(:reponse1) { create(:choix, :avec_illustration, :bon, question_id: question.id) }
    let!(:reponse2) { create(:choix, :bon, question_id: question.id) }
    let(:json) { question.as_json }

    it 'serialise les champs' do
      intitule = create(:transcription, :avec_audio, question_id: question.id,
                                                     ecrit: 'Mon Intitulé')
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique
                                          description illustration modalite_reponse type
                                          reponsesNonClassees])
      expect(json['type']).to eql('glisser_deposer_billets')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question.illustration
                                          ))
      expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                         intitule.audio
                                       ))
      expect(json['reponsesNonClassees'].size).to eql(2)
      expect(json['reponsesNonClassees'].first['illustration']).to eql(
        Rails.application.routes.url_helpers.url_for(
          reponse1.illustration
        )
      )
    end
  end
end
