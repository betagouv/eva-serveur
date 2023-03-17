# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionSaisie, type: :model do
  describe '#as_json' do
    it 'serialise les champs' do
      subject.reponse_placeholder = 'ecrivez ici'
      json = subject.as_json
      expect(json.keys).to match_array(%w[id intitule nom_technique suffix_reponse
                                          description type sous_type placeholder])
      expect(json['type']).to eql('saisie')
      expect(json['sous_type']).to eql('redaction')
      expect(json['placeholder']).to eql('ecrivez ici')
    end
  end
end
