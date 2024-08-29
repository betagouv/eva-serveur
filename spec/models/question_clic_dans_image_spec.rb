# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionClicDansImage, type: :model do
  it { is_expected.to have_one_attached(:zone_cliquable) }

  describe '#as_json' do
    let(:question_clic_dans_image) do
      create(:question_clic_dans_image,
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ),
             zone_cliquable: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/accessibilite-avec-reponse.svg')
             ))
    end

    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_clic_dans_image.id,
                                          categorie: :modalite_reponse,
                                          ecrit: 'Ma modalité')
    end

    it 'serialise les champs' do
      intitule = create(:transcription, :avec_audio, question_id: question_clic_dans_image.id,
                                                     ecrit: 'Mon Intitulé')
      json = question_clic_dans_image.as_json
      expect(json.keys)
        .to match_array(%w[description id intitule audio_url nom_technique type illustration
                           modalite_reponse zone_cliquable])
      expect(json['type']).to eql('clic_dans_image')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_clic_dans_image.illustration
                                          ))
      expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                         intitule.audio
                                       ))
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
      expect(json['zone_cliquable']).to start_with('data:image/svg+xml;base64,')
    end

    context "quand il n'y a pas d'intitulé écrit" do
      let!(:intitule) do
        create(:transcription, :avec_audio, question_id: question_clic_dans_image.id, ecrit: '')
      end

      it "retourne l'audio de la modalité de réponse comme audio de la question" do
        json = question_clic_dans_image.as_json
        expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                           modalite.audio
                                         ))
      end

      it "retourne l'audio de l'intitulé comme audio secondaire" do
        json = question_clic_dans_image.as_json
        expect(json['intitule_audio']).to eql(Rails.application.routes.url_helpers.url_for(
                                                intitule.audio
                                              ))
      end
    end
  end

  describe 'validations' do
    let(:question) do
      build(:question_clic_dans_image)
    end

    context 'avec un attachment au format svg' do
      it 'est valide' do
        question.zone_cliquable.attach(
          io: Rails.root.join('spec/support/accessibilite-sans-reponse.svg').open,
          filename: 'valid.svg',
          content_type: 'image/svg+xml'
        )
        expect(question).to be_valid
      end
    end

    context "avec un attachement d'un autre format" do
      it "n'est pas valide" do
        question.zone_cliquable.attach(
          io: Rails.root.join('spec/support/programme_tele.png').open,
          filename: 'invalid.png',
          content_type: 'image/png'
        )
        expect(question).not_to be_valid
        expect(question.errors[:zone_cliquable]).to include("n'est pas un format de fichier valide")
      end
    end
  end
end
