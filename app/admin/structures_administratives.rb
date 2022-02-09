# frozen_string_literal: true

ActiveAdmin.register StructureAdministrative do
  menu parent: 'Terrain', if: proc { can?(:manage, Compte) }

  permit_params :nom, :structure_referente_id

  filter :nom
  filter :created_at

  index do
    column :nom
    column :created_at do |structure|
      l(structure.created_at, format: :court)
    end
    actions
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

    def trouve_structures_dependantes
      return unless can?(:manage, Compte)

      @structures_dependantes = Structure.where(structure_referente: resource)
    end
  end
end
