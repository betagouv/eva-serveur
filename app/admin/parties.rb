# frozen_string_literal: true

ActiveAdmin.register Partie do
  belongs_to :situation
  includes evaluation: :campagne

  actions :index, :show

  config.sort_order = 'created_at_desc'

  scope :all, default: true
  scope(:terminees) { |scope| scope.where(session_id: session_ids_des_evenements_fin) }
  scope(:non_terminees) { |scope| scope.where.not(session_id: session_ids_des_evenements_fin) }

  filter :evaluation
  filter :session
  filter :created_at
  filter :updated_at

  index do
    column :evaluation
    column :metriques
    column :created_at
    actions do |partie|
      link_to t('.evenements'),
              admin_campagne_evenements_path(
                partie.campagne,
                q: { 'session_id_equals' => partie.session_id }
              )
    end
  end

  controller do
    helper_method :session_ids_des_evenements_fin

    def session_ids_des_evenements_fin
      Evenement.where(nom: Restitution::Base::EvenementsHelper::EVENEMENT[:FIN_SITUATION])
               .select(:session_id)
    end

    def scoped_collection
      Partie.where(situation_id: params[:situation_id])
            .joins(evaluation: { campagne: :compte })
            .where.not(comptes: { role: :superadmin })
    end
  end
end
