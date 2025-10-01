require 'rails_helper'

describe StructuresController, type: :controller do
  describe 'GET index' do
    let(:stub_structures_collection) { double(where: double(not: [])) }

    context 'quand je ne passe pas de paramètre' do
      it 'ne recherche pas les structures' do
        expect(StructureLocale).not_to receive(:where)
        expect(StructureLocale).not_to receive(:near)
        get :index, params: {}
      end
    end

    context 'quand je passe des paramètres' do
      it 'recherche les structures de la ville' do
        expect(StructureLocale).to receive(:where).with(code_postal: '61000')
        expect(StructureLocale).to receive(:near).with('Alençon (61000), FRANCE')
                                                 .and_return(stub_structures_collection)
        get :index, params: { ville_ou_code_postal: 'Alençon (61000)', code_postal: '61000' }
      end
    end
  end

  describe 'GET show' do
    context 'quand la structure est une structure locale' do
      it 'retourne vers le détail de la structure locale' do
        structure = create :structure_locale

        get :show, params: { id: structure.id }
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to(admin_structure_locale_url(structure))
      end
    end

    context 'quand la structure est une structure administrative' do
      it 'retourne vers le détail de la structure administrative' do
        structure = create :structure_administrative

        get :show, params: { id: structure.id }
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to(admin_structure_administrative_url(structure))
      end
    end
  end
end
