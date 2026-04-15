require 'rails_helper'

describe 'Admin - Compte#rejoindre_structure', type: :request do
  let!(:structure) { create :structure_locale, :avec_admin }
  let(:compte) { create :compte_conseiller, :en_attente, structure: nil }

  before { sign_in compte }

  it 'rejoint la structure et redirige vers le dashboard' do
    patch rejoindre_structure_admin_compte_path(compte, structure_id: structure.id)

    expect(response).to redirect_to(admin_dashboard_path)
    expect(compte.reload.structure).to eq structure
    expect(compte.role).to eq 'conseiller'
  end

  it "redirige vers le dashboard si la structure n'existe pas" do
    patch rejoindre_structure_admin_compte_path(compte, structure_id: 'inexistant')

    expect(response).to redirect_to(admin_dashboard_path)
    expect(compte.reload.structure).to be_nil
  end

  context 'avec une structure sans admin' do
    let!(:structure_sans_admin) { create :structure_locale }

    it 'devient admin de la structure' do
      patch rejoindre_structure_admin_compte_path(compte, structure_id: structure_sans_admin.id)

      expect(response).to redirect_to(admin_dashboard_path)
      expect(compte.reload.structure).to eq structure_sans_admin
      expect(compte.role).to eq 'admin'
    end
  end
end
