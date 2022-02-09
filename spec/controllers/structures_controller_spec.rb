# frozen_string_literal: true

require 'rails_helper'

describe StructuresController, type: :controller do
  describe 'GET index' do
    it 'recherche un code postal en France' do
      expect(StructureLocale).to receive(:near).with('75001, FRANCE')
      get :index, params: { code_postal: '75001' }
    end
  end
end
