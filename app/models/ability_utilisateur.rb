# frozen_string_literal: true

class AbilityUtilisateur
  include CanCan::Ability
  attr_reader :compte

  def initialize(compte)
    @compte = compte

    droits_generiques compte
    droit_campagne compte
    droit_evaluation compte
    droit_evenement compte
    droit_restitution compte
    droit_compte compte
    droit_structure compte
    droit_actualite compte
    droits_cmr if compte.charge_mission_regionale?
  end

  def can_update_active_pour_campagne?(campagne)
    @compte.au_moins_admin? || campagne.compte_id == @compte.id
  end

  private
  def droit_campagne(compte)
    can %i[create duplique], Campagne if can_create_campagne?(compte)
    can %i[update read], Campagne,
comptes_de_meme_structure(compte).merge(privee: false) if compte.validation_acceptee?
    can %i[update read destroy], Campagne, compte_id: compte.id
    can(:destroy, Campagne) { |c| Evaluation.where(campagne: c).empty? }
  end

  def droits_generiques(compte)
    can :manage, :all if compte.superadmin?
    cannot :destroy, Campagne
  end

  def droit_evaluation(compte)
    cannot %i[create], Evaluation
    can %i[read destroy], Evaluation, campagne: { compte_id: compte.id }
    return unless compte.validation_acceptee? && compte.structure_id.present?

    can %i[read mise_en_action supprimer_responsable_suivi
           ajouter_responsable_suivi renseigner_qualification],
        Evaluation,
        campagne: comptes_de_meme_structure(compte).merge(privee: false)

    can :read, Evaluation, responsable_suivi_id: compte.id

    return unless compte.admin?

    can %i[update destroy], Evaluation,
        campagne: comptes_de_meme_structure(compte)
  end

  def droit_evaluation(compte)
    cannot :create, Evaluation
    can :read, Evaluation, responsable_suivi_id: compte.id
    can %i[read destroy], Evaluation, campagne: { compte_id: compte.id }

    if compte.validation_acceptee? && compte.structure_id.present?
      can %i[read mise_en_action supprimer_responsable_suivi
             ajouter_responsable_suivi renseigner_qualification],
          Evaluation,
          campagne: { compte: { structure_id: compte.structure_id }, privee: false }
    end

    if compte.admin? && compte.structure_id.present?
      can %i[update destroy], Evaluation,
          campagne: { compte: { structure_id: compte.structure_id }, privee: false }
    end
  end

  def droit_evenement(compte)
    cannot %i[update create], Evenement

    @session_ids ||= Partie.where("comptes.structure_id" => compte.structure_id)
                           .joins(evaluation: { campagne: :compte }).pluck(:session_id)
    can :read, Evenement, Evenement.where(session_id: @session_ids) do |e|
      @session_ids.include?(e.session_id)
    end
  end

  def droit_restitution(compte)
    can :manage, Restitution::Base, campagne: comptes_de_meme_structure(compte)
  end

  def droit_compte(compte)
    can :read, Compte, structure_id: compte.structure_id if compte.validation_acceptee?
    can :read, compte
    can :update, compte
    can :rejoindre_structure, compte
    can :accepter_cgu, compte
    comptes_generiques_ou_comptes_admin(compte)
    droits_validation_comptes(compte)
    cannot(:destroy, Compte) { |c| Campagne.exists?(compte: c) }
    cannot :update, compte if compte.email == Eva::EMAIL_DEMO
  end

  def droit_structure(compte)
    can :read, Structure, id: compte.structure_id if compte.validation_acceptee?
    can :update, Structure, id: compte.structure_id if compte.admin?
    cannot(:destroy, Structure) { |s| Compte.exists?(structure: s) }
    return if compte.structure_id.present?

    can :read, ActiveAdmin::Page, name: "recherche_structure",
                                  namespace_name: "admin"
    can :create, StructureLocale
  end

  def droit_actualite(compte)
    can :read, Actualite
    can :manage, Actualite if compte.superadmin?
  end

  def droits_cmr
    can :read, :all
    cannot(%i[update create destroy], :all)
    cannot(:read, AnnonceGenerale)
    cannot(:read, Beneficiaire)
    cannot(:read, SourceAide)
    cannot(%i[supprimer_responsable_suivi ajouter_responsable_suivi
              renseigner_qualification],
           Evaluation)
  end

  def comptes_de_meme_structure(compte)
    { compte: { structure_id: compte.structure_id } }
  end

  def comptes_generiques_ou_comptes_admin(compte)
    return unless compte.admin? || compte.compte_generique?

    can :create, Compte
    can :update, Compte, structure_id: compte.structure_id
    can :edit_role, Compte, structure_id: compte.structure_id
    cannot :edit_role, compte if compte.compte_generique?
    can :destroy, Compte, structure_id: compte.structure_id, role: :conseiller
  end

  def droits_validation_comptes(compte)
    can %i[autoriser refuser], Compte, structure_id: compte.structure_id if compte.au_moins_admin?
    cannot :refuser, Compte, &:au_moins_admin?
  end

  def can_create_campagne?(compte)
    compte.structure&.autorisation_creation_campagne || compte.admin? || compte.superadmin?
  end
end
