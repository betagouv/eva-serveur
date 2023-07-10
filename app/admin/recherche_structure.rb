# frozen_string_literal: true

ActiveAdmin.register_page 'recherche_structure' do
  menu false

  content title: proc { I18n.t('active_admin.recherche_structure') } do
    render partial: 'recherche_structure'
  end

  controller do
    def index
      return if params[:ville_ou_code_postal].blank?

      @structures_code_postal = StructureLocale.where(code_postal: params[:code_postal])
      @structures = StructureLocale.near("#{params[:ville_ou_code_postal]}, FRANCE")
                                   .where.not(id: @structures_code_postal)
    end
  end
end
