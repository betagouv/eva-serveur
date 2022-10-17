# frozen_string_literal: true

require 'rails_helper'

describe ParcoursType, type: :integration do
  describe 'suppression' do
    context 'quand il y a une campagne soft delete associée' do
      let(:parcours_type) { create :parcours_type }

      before do
        campagne = create :campagne, parcours_type: parcours_type
        campagne.destroy
      end

      it do
        expect do
          parcours_type.destroy
        end.to change { ParcoursType.count }.by(-1)
      end
    end
  end
end
