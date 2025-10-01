require 'rails_helper'

describe Api::EvaluationsController do
  let(:compte) { create :compte_admin }
  let(:campagne) { create :campagne, compte: compte }

  describe "creation" do
    context "avec un nom d'évaluation" do
      let(:evaluation_params) do
        {
          nom: "Nom du bénéficiaire",
          debutee_le: DateTime.current,
          code_campagne: campagne.code
        }
      end

      it "ajoute bien une evaluation à la création" do
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

    context "avec un code bénéficiaire" do
      let(:beneficiaire) { create :beneficiaire }
      let(:evaluation_params) do
        {
          code_beneficiaire: beneficiaire.code_beneficiaire,
          debutee_le: DateTime.current,
          code_campagne: campagne.code
        }
      end

      it "ajoute l'évaluation au bénéficiaire" do
        expect do
          post :create, params: evaluation_params
        end.to change(Evaluation, :count).by(1)
        expect(Evaluation.last.beneficiaire).to eq(beneficiaire)
      end
    end
  end

  describe "update" do
    it "la mise à jour d'une évaluation ne change pas le nombre de bénéficiaire" do
      evaluation = create :evaluation
      expect do
        put :update, params: { id: evaluation.id, nom: "n'importe quel autre nom est ignoré" }
      end.not_to(change(Beneficiaire, :count))
      expect(response).to have_http_status(:success)
    end
  end
end
