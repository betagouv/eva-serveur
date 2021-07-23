# frozen_string_literal: true

ActiveAdmin.register DemandeAccompagnement do
  belongs_to :evaluation, optional: true
  menu false
  permit_params :conseiller_nom, :conseiller_prenom, :conseiller_email,
                :conseiller_telephone, :probleme_rencontre, :probleme_rencontre_custom,
                :compte_id, :evaluation_id

  # rubocop:disable Lint/ConstantDefinitionInBlock
  class Evaluation < ApplicationRecord
    has_many :demandes_accompagnement
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  form partial: 'form'

  controller do
    before_action :evaluation, only: %i[new create edit update]
    before_action :assigne_valeurs_par_defaut, only: %i[new create]
    helper_method :collection_problemes_rencontre

    private

    def evaluation
      @evaluation = Evaluation.find params[:evaluation_id]
    end

    def assigne_valeurs_par_defaut
      params[:demande_accompagnement] ||= {}
      params[:demande_accompagnement][:compte_id] ||= current_compte.id
      params[:demande_accompagnement][:evaluation_id] ||= @evaluation.id
      assigne_probleme_rencontre
    end

    def assigne_probleme_rencontre
      demande_accompagnement = params[:demande_accompagnement]
      if DemandeAccompagnement::PROBLEMES_RENCONTRE_COURANTS.include?(
        demande_accompagnement[:probleme_rencontre]
      )
        return
      end

      demande_accompagnement[:probleme_rencontre] =
        demande_accompagnement[:probleme_rencontre_custom]
    end

    def collection_problemes_rencontre
      collection = []
      collection.push DemandeAccompagnement::PROBLEMES_RENCONTRE_COURANTS
      collection.push('Autre')
      collection.flatten!
    end
  end
end
