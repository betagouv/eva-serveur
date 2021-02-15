# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionRedactionNote, type: :model do
  describe '#as_json' do
    let(:file) { StringIO.new('test') }

    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[id description intitule type
                                          intitule_reponse reponse_placeholder])
      expect(json['type']).to eql('redaction_note')
    end

    it "serialise l'illustration" do
      subject.illustration.attach(io: file, filename: 'test.png')
      json = subject.as_json
      expect(json.keys).to include('illustration')
    end
  end
end
