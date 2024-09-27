# frozen_string_literal: true

require 'rails_helper'

describe Api::EvaluationsController do
  let(:compte) { create :compte_admin }
  let(:campagne) { create :campagne, compte: compte }
  let(:nom) { 'Evaluation de test nom' }
  let(:evaluation_params) do
    {
      nom: nom,
      debutee_le: DateTime.current,
      code_campagne: campagne.code
    }
  end

  describe 'creation' do
    it 'ajoute bien une evaluation à la création' do
      expect do
        post :create, params: evaluation_params
      end.to change(Evaluation, :count).by(1)
    end

    it "lorsqu'on crée une evaluation, on crée un bénéficiaire" do
      expect do
        post :create, params: evaluation_params
      end.to change(Beneficiaire, :count).by(1)
    end
  end

  describe 'update' do
    it "mets à jour le nom de l'évaluation" do
      evaluation = create :evaluation
      put :update, params: { id: evaluation.id, nom: nom }
      expect(evaluation.reload.nom).to eq(nom)
    end

    it "la mise à jour d'une évaluation ne change pas le nombre de bénéficiaire" do
      evaluation = create :evaluation
      expect do
        put :update, params: { id: evaluation.id, nom: nom }
      end.not_to(change(Beneficiaire, :count))
      expect(response).to have_http_status(:success)
    end
  end
end
