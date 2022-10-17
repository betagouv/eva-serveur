# frozen_string_literal: true

require 'rails_helper'

describe Questionnaire, type: :integration do
  describe 'suppression' do
    context 'quand il y a une campagne soft delete associée' do
      let(:questionnaire) { create :questionnaire }

      before do
        campagne = create :campagne, questionnaire: questionnaire
        campagne.destroy
      end

      it do
        expect do
          questionnaire.destroy
        end.to change { Questionnaire.count }.by(-1)
      end
    end
  end
end
