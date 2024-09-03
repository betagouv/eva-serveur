# frozen_string_literal: true

require 'rails_helper'

describe Admin::Positionnement::ReponsesController do
  let(:situation) { create(:situation) }
  let(:evaluation) { create :evaluation }
  let!(:partie) { create :partie, evaluation: evaluation, situation: situation }
  let!(:compte) { create :compte_superadmin }

  before do
    sign_in compte
  end

  it 'retourne un fichier xls' do
    get :show, params: { partie_id: partie.id }

    expect(response.header['Content-Type']).to include 'excel'
    expect(response).to have_http_status(:success)
  end

  context "lorsque l'un des params est manquant" do
    it 'retourne un fichier xls' do
      get :show, params: { partie_id: partie.id }
      expect(response).to have_http_status(:success)
    end
  end

  context "lorsque l'utilisateur n'a pas les droits" do
    before do
      allow(controller).to receive(:can_read_partie?).and_return(false)
    end

    it "redirige vers l'accueil et stop la méthode" do
      get :show, params: { partie_id: partie.id }
      expect(controller).not_to receive(:send_data)
      expect(response).to redirect_to(root_path)
    end
  end
end
