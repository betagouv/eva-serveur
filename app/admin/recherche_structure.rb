# frozen_string_literal: true

ActiveAdmin.register_page 'recherche_structure' do
  menu false

  content title: proc { I18n.t('structures.index.title') } do
    render partial: 'recherche_structure'
  end

  controller do
    def index
      @recherche_structure_component = RechercheStructureComponent.new(
        recherche_url: 'recherche_structure',
        current_compte: @current_compte,
        ville_ou_code_postal: params[:ville_ou_code_postal],
        code_postal: params[:code_postal]
      )
    end
  end
end
