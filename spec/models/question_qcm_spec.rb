# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionQcm, type: :model do
  it { is_expected.to have_many(:choix).order(position: :asc).with_foreign_key(:question_id) }

  describe '#as_json' do
    it 'serialise les champs' do
      question_qcm = create(:question_qcm, transcription_ecrit: 'Mon Intitulé')

      json = question_qcm.as_json
      expect(json.keys)
        .to match_array(%w[choix description id intitule nom_technique type metacompetence
                           type_qcm])
      expect(json['type']).to eql('qcm')
      expect(json['intitule']).to eql('Mon Intitulé')
    end
  end
end
