require 'rails_helper'

describe CampagneDuplicateur, type: :model do
  let(:campagne) do
    parcours_type = create(:parcours_type, :avec_situations_configurations)
    campagne = create(:campagne, :avec_situations_configurations, parcours_type: parcours_type)
    campagne.type_programme = nil
    campagne
  end
  let(:current_compte) { create(:compte) }
  let(:duplicateur) { described_class.new(campagne, current_compte) }

  describe '#duplique!' do
    it 'duplique la campagne' do
      duplicated_campagne = duplicateur.duplique!

      expect(duplicated_campagne).to be_persisted
      expect(duplicated_campagne).not_to eq(campagne)
      expect(duplicated_campagne.libelle).to eq("#{campagne.libelle} - copie")
      expect(duplicated_campagne.compte_id).to eq(current_compte.id)
    end

    it 'duplique les associations de la campagne' do
      duplicated_campagne = duplicateur.duplique!

      expect(duplicated_campagne.situations_configurations.count).to eq(
        campagne.situations_configurations.count
      )
      duplicated_campagne.situations_configurations.each_with_index do |duplicated_config, index|
        original_config = campagne.situations_configurations[index]
        expect(duplicated_config.situation_id).to eq(original_config.situation_id)
        expect(duplicated_config.questionnaire_id).to eq(original_config.questionnaire_id)
      end
    end
  end
end
