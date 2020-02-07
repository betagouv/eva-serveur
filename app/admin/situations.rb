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

  action_item :lien_recalcule, only: :show, priority: 0 do
    link_to I18n.t('admin.situations.recalcul_metriques.lien'),
            recalcule_metriques_admin_situation_path(resource),
            method: :post
  end

  member_action :recalcule_metriques, method: :post do
    Partie
      .where(situation: resource)
      .where.not(metriques: {})
      .find_each(&:persiste_restitution)

    redirect_to admin_situation_path(resource),
                notice: I18n.t('admin.situations.recalcul_metriques.fait')
  end
end
