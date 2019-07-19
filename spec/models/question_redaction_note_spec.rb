# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionRedactionNote, type: :model do
  describe '#as_json' do
    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[entete_reponse expediteur id intitule
                                          message objet_reponse type])
      expect(json['type']).to eql('redaction_note')
    end
  end
end
