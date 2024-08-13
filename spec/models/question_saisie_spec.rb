# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionSaisie, type: :model do
  it { is_expected.to have_one(:choix).with_foreign_key(:question_id) }

  describe '#as_json' do
    it 'serialise les champs' do
      question_saisie = create(:question_saisie, transcription_ecrit: 'Mon Intitulé')
      reponse = create(:choix, :bon, question_id: question_saisie.id)
      question_saisie.update(reponse_placeholder: 'écrivez ici')

      json = question_saisie.as_json
      expect(json.keys).to match_array(%w[id intitule nom_technique suffix_reponse
                                          description type sous_type placeholder reponse])
      expect(json['type']).to eql('saisie')
      expect(json['sous_type']).to eql('redaction')
      expect(json['placeholder']).to eql('écrivez ici')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['reponse']).to eql(reponse.intitule)
    end
  end
end
