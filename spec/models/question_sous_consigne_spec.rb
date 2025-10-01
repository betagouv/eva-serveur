require 'rails_helper'

describe QuestionSousConsigne, type: :model do
  describe '#as_json' do
    let(:question_sous_consigne) do
      create(:question_sous_consigne,
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ))
    end
    let(:json) { question_sous_consigne.as_json }

    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique illustration type])
      expect(json['type']).to eql('sous-consigne')
    end

    it "retourne l'illustration" do
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_sous_consigne.illustration.variant(:defaut)
                                          ))
    end
  end
end
