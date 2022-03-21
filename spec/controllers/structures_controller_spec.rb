# frozen_string_literal: true

require 'rails_helper'

describe StructuresController, type: :controller do
  describe 'GET index' do
    it 'recherche un code postal en France' do
      expect(StructureLocale).to receive(:near).with('75001, FRANCE')
      get :index, params: { code_postal: '75001' }
    end
  end

  describe 'GET show' do
    context 'quand la structure est une structure locale' do
      it 'retourne vers le détail de la structure locale' do
        structure = create :structure_locale

        get :show, params: { id: structure.id }
        expect(response).to have_http_status(301)
        expect(response).to redirect_to(admin_structure_locale_url(structure))
      end
    end

    context 'quand la structure est une structure administrative' do
      it 'retourne vers le détail de la structure administrative' do
        structure = create :structure_administrative

        get :show, params: { id: structure.id }
        expect(response).to have_http_status(301)
        expect(response).to redirect_to(admin_structure_administrative_url(structure))
      end
    end
  end
end
