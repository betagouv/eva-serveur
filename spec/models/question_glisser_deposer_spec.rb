# frozen_string_literal: true

require 'rails_helper'

describe QuestionGlisserDeposer, type: :model do
  it { is_expected.to have_many(:reponses).with_foreign_key(:question_id) }
  it { is_expected.to have_many_attached(:zones_depot_url) }

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
  let!(:reponse1) do
    create(:choix, :avec_illustration, :bon, question_id: question.id, position_client: 2)
  end
  let!(:reponse2) { create(:choix, :avec_illustration, :bon, question_id: question.id) }
  let(:json) { question.as_json }

  describe '#as_json' do
    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique
                                          description illustration modalite_reponse type
                                          reponsesNonClassees])
      expect(json['type']).to eql('glisser-deposer-billets')
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question.illustration
                                          ))
    end

    describe 'les reponsesNonClassees' do
      it do
        expect(json['reponsesNonClassees'].size).to eql(2)
        expect(json['reponsesNonClassees'].first['illustration']).to_not be(nil)
        expect(json['reponsesNonClassees'].first['position']).to eql(1)
        expect(json['reponsesNonClassees'].first['position_client']).to eql(2)
      end
    end
  end

  describe 'validations' do
    let(:question) do
      build(:question_glisser_deposer)
    end

    context 'avec un attachment au format svg' do
      it 'est valide' do
        question.zones_depot_url.attach(
          io: Rails.root.join('spec/support/accessibilite-sans-reponse.svg').open,
          filename: 'valid.svg',
          content_type: 'image/svg+xml'
        )
        expect(question).to be_valid
      end
    end

    context "avec un attachement d'un autre format" do
      it "n'est pas valide" do
        question.zones_depot_url.attach(
          io: Rails.root.join('spec/support/programme_tele.png').open,
          filename: 'invalid.png',
          content_type: 'image/png'
        )
        expect(question).not_to be_valid
        erreur = question.errors[:zones_depot_url]
        expect(erreur).to include("n'est pas un format de fichier valide")
      end
    end
  end
end
