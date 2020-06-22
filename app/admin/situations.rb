# frozen_string_literal: true

ActiveAdmin.register Situation do
  permit_params :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id

  form do |f|
    f.semantic_errors
    inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :questionnaire
      f.input :questionnaire_entrainement
    end
    f.actions
  end

  index do
    column :libelle
    column :nom_technique
    column :questionnaire
    column :questionnaire_entrainement
    actions do |situation|
      link_to 'Parties', admin_situation_parties_path(situation)
    end
  end

  action_item :lien_recalcule, only: :show, priority: 0 do
    link_to I18n.t('admin.situations.recalcul_metriques.lien'),
            recalcule_metriques_admin_situation_path(resource),
            method: :post
  end

  member_action :recalcule_metriques, method: :post do
    Partie
      .where(situation: resource)
      .find_each do |partie|
        restitution = FabriqueRestitution.instancie partie.id
        restitution.persiste if restitution.termine?
      end

    redirect_to admin_situation_path(resource),
                notice: I18n.t('admin.situations.recalcul_metriques.fait')
  end
end
