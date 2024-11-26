# frozen_string_literal: true

require 'rails_helper'

describe QuestionGlisserDeposer, type: :model do
  let!(:question) do
    create(:question_glisser_deposer,
           illustration: Rack::Test::UploadedFile.new(
             Rails.root.join('spec/support/programme_tele.png')
           ),
           zone_depot: Rack::Test::UploadedFile.new(
             Rails.root.join('spec/support/N1Pse1-zone-depot-valide.svg')
           ))
  end
  let(:json) { question.as_json }
  let!(:reponse1) do
    create(:choix, :avec_illustration, :bon, question_id: question.id, position_client: 2)
  end
  let!(:reponse2) { create(:choix, :avec_illustration, :bon, question_id: question.id) }
  let!(:modalite) do
    create(:transcription, :avec_audio, question_id: question.id,
                                        categorie: :modalite_reponse)
  end

  it { is_expected.to have_many(:reponses).with_foreign_key(:question_id) }
  it { is_expected.to have_one_attached(:zone_depot) }

  describe '#as_json' do
    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique
                                          description illustration modalite_reponse type
                                          reponsesNonClassees zone_depot_url consigne_audio
                                          intitule_audio demarrage_audio_modalite_reponse])
      expect(json['type']).to eql('glisser-deposer')
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question.illustration
                                          ))
      expect(json['zone_depot_url']).to start_with('data:image/svg+xml;base64,')
    end

    describe 'les reponsesNonClassees' do
      it do
        expect(json['reponsesNonClassees'].size).to be(2)
        expect(json['reponsesNonClassees'].first['illustration']).not_to be_nil
        expect(json['reponsesNonClassees'].first['position']).to be(1)
        expect(json['reponsesNonClassees'].first['position_client']).to be(2)
        expect(json['reponsesNonClassees'].first['nom_technique']).to eql(reponse1.nom_technique)
      end
    end
  end

  describe 'validations' do
    let(:question) do
      build(:question_glisser_deposer)
    end

    context 'avec un attachment au format svg' do
      it 'est valide' do
        question.zone_depot.attach(
          io: Rails.root.join('spec/support/accessibilite-sans-reponse.svg').open,
          filename: 'valid.svg',
          content_type: 'image/svg+xml'
        )
        expect(question).to be_valid
      end
    end

    context "avec un attachement d'un autre format" do
      it "n'est pas valide" do
        question.zone_depot.attach(
          io: Rails.root.join('spec/support/programme_tele.png').open,
          filename: 'invalid.png',
          content_type: 'image/png'
        )
        expect(question).not_to be_valid
        erreur = question.errors[:zone_depot]
        expect(erreur).to include("n'est pas un format de fichier valide")
      end
    end
  end
end
