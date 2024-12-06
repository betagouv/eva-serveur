# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionQcm, type: :model do
  it { is_expected.to have_many(:choix).order(position: :asc).with_foreign_key(:question_id) }

  it do
    expect(subject).to define_enum_for(:metacompetence).with_values(Metacompetence::METACOMPETENCES)
  end

  describe '#as_json' do
    let(:question_qcm) do
      create(:question_qcm, illustration: Rack::Test::UploadedFile.new(
        Rails.root.join('spec/support/programme_tele.png')
      ))
    end

    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_qcm.id,
                                          categorie: :modalite_reponse,
                                          ecrit: 'Ma modalité')
    end

    it 'serialise les champs' do
      intitule = create(:transcription, :avec_audio, question_id: question_qcm.id,
                                                     ecrit: 'Mon Intitulé')
      choix = create(:choix, :bon, :avec_audio, question_id: question_qcm.id)

      json = question_qcm.as_json
      expect(json.keys)
        .to match_array(%w[choix description id intitule audio_url nom_technique type metacompetence
                           type_qcm illustration modalite_reponse consigne_audio
                           demarrage_audio_modalite_reponse])
      expect(json['type']).to eql('qcm')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_qcm.illustration
                                          ))
      expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                         intitule.audio
                                       ))
      expect(json['choix'][0]['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                                     choix.audio
                                                   ))
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
    end
  end
end
