# frozen_string_literal: true

require 'rails_helper'

describe Evaluation, type: :integration do
  context 'quand la mise en action est renseignée' do
    let(:evaluation) { create :evaluation }

    it 'enregistre la date du jour' do
      expect(evaluation.mise_en_action_le).to eq nil
      date_du_jour = Time.zone.local(2023, 1, 1, 12, 0, 0)
      Timecop.freeze(date_du_jour) do
        evaluation.update(mise_en_action_effectuee: true)

        expect(evaluation.mise_en_action_le).to match(date_du_jour)
      end
    end
  end
end
