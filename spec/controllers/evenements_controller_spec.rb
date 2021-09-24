# frozen_string_literal: true

require 'rails_helper'

describe Api::EvenementsController, type: :controller do
  describe 'POST create' do
    context "quand la création de l'évènement échoue" do
      it 'ne crée pas de partie' do
        evaluation = create :evaluation
        create :situation_inventaire
        params = {
          date: 1_551_111_089_238,
          nom: nil,
          donnees: {},
          situation: 'inventaire',
          position: 58,
          session_id: 'O8j78U2xcb2',
          evaluation_id: evaluation.id
        }

        expect do
          post :create, params: params
        end.to change(Partie, :count)
          .by(0)
          .and change(Evenement, :count)
          .by(0)
      end
    end
  end
end
