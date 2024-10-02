# frozen_string_literal: true

ActiveAdmin.register StructureAdministrative do
  menu parent: 'Terrain', if: proc { current_compte.anlci? }

  permit_params :nom, :parent_id, :siret

  filter :nom
  filter :created_at

  index do
    column :nom do |sa|
      link_to sa.nom, admin_structure_administrative_path(sa)
    end
    column :created_at do |structure|
      l(structure.created_at, format: :sans_heure)
    end
    actions
    column '', class: 'bouton-action' do
      render partial: 'components/bouton_menu_actions'
    end
  end

  show do
    render partial: 'admin/structures/show', locals: { structure: resource }
  end

  form partial: 'form'

  controller do
    before_action :trouve_comptes, :trouve_campagnes, :trouve_structures_dependantes, only: :show

    def trouve_comptes
      comptes = Compte.where(structure: resource).order(:prenom, :nom)
      @comptes_en_attente = comptes.validation_en_attente
      @comptes_refuses = comptes.validation_refusee
      @comptes_acceptes = comptes.validation_acceptee
    end

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def statistiques_structure
      StatistiquesStructure.new(resource).nombre_evaluations_des_12_derniers_mois
    end

    def trouve_structures_dependantes
      return unless current_compte.anlci?

      @structures_dependantes = Structure.where(structure_referente: resource)
    end
  end
end
