# frozen_string_literal: true

require 'rails_helper'

describe QuestionClicDansTexte, type: :model do
  describe '#as_json' do
    let(:contenu) { 'Mon Intitulé [mot1](#bonne-reponse) [mot2](#bonne-reponse) [mot3]()' }
    let(:question_clic_dans_texte) do
      create(:question_clic_dans_texte,
             texte_sur_illustration: contenu,
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ))
    end
    let(:json) { question_clic_dans_texte.as_json }

    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id nom_technique description texte_cliquable
                                          illustration reponse type])
      expect(json['type']).to eql('clic-sur-mots')
      expect(json['texte_cliquable']).to eql(contenu)
      expect(json['description']).to eql(question_clic_dans_texte.description)
      expect(json['reponse']['bonne_reponse']).to eql(%w[mot1 mot2])
    end

    it "retourne l'illustration" do
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_clic_dans_texte.illustration
                                          ))
    end
  end
end
