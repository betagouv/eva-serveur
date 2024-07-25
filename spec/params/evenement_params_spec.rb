# frozen_string_literal: true

require 'rails_helper'

describe EvenementParams do
  describe '#from' do
    let!(:situation) { create :situation_inventaire }

    it 'filtre les parametres' do
      params = ActionController::Parameters.new(
        nom: 'mon nom',
        date: 1_580_743_539_508,
        donnees: {},
        session_id: 'ma session id',
        situation: 'autre paramètre',
        evaluation_id: 'id'
      )

      evenement_params = described_class.from(params)
      expect(evenement_params[:date]).to eql(Time.zone.at(1_580_743_539, 508, :millisecond))
      expect(evenement_params.keys.sort).to eql(
        %w[date donnees nom session_id]
      )
    end
  end
end
