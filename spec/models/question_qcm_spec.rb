# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionQcm, type: :model do
  it { should have_many(:choix).order(position: :asc).with_foreign_key(:question_id) }

  describe '#as_json' do
    let(:file) { StringIO.new('test') }

    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys)
        .to match_array(%w[choix description id intitule type metacompetence
                           type_qcm])
      expect(json['type']).to eql('qcm')
    end

    it "serialise l'illustration" do
      subject.illustration.attach(io: file, filename: 'test.png')
      json = subject.as_json
      expect(json.keys).to include('illustration')
    end
  end
end
