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
    get :show,
        params: { partie_numeratie_id: partie.id, partie_litteratie_id: partie.id }

    expect(response.header['Content-Type']).to include 'excel'
    expect(response).to have_http_status(:success)
  end

  it "genere le nom du fichier en fonction de l'évaluation" do
    code_de_campagne = partie.evaluation.campagne.code.parameterize
    nom_de_levaluation = partie.evaluation.nom.parameterize.first(15)
    date = DateTime.current.strftime('%Y%m%d')
    nom_du_fichier_attendu = "#{date}-#{nom_de_levaluation}-#{code_de_campagne}.xls"

    expect(subject.nom_du_fichier(partie)).to eq(nom_du_fichier_attendu)
  end

  context "lorsque l'un des params est manquant" do
    it 'retourne un fichier xls' do
      get :show, params: { partie_numeratie_id: partie.id }
      expect(response).to have_http_status(:success)
    end
  end

  context "lorsque l'utilisateur n'a pas les droits" do
    before do
      allow(controller).to receive(:abilities?).and_return(false)
    end

    it "redirige vers l'accueil et stop la méthode" do
      get :show, params: { partie_numeratie_id: partie.id, partie_litteratie_id: partie.id }
      expect(controller).not_to receive(:send_data)
      expect(response).to redirect_to(root_path)
    end
  end
end
