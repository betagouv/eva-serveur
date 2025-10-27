class AbilityUtilisateur
  include CanCan::Ability
  attr_reader :compte

  def initialize(compte)
    @compte = compte

    droits_superadmin compte
    droit_campagne compte
    droit_evaluation compte
    droit_beneficiaire compte
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

  def droits_superadmin(compte)
    can :manage, :all if compte.superadmin?
  end

  def droit_campagne(compte)
    cannot :destroy, Campagne
    can(:destroy, Campagne) { |c| Evaluation.where(campagne: c).empty? }
    can %i[read update autoriser_compte revoquer_compte destroy], Campagne, compte_id: compte.id
    can %i[create duplique], Campagne if can_create_campagne?(compte)
    can %i[read], Campagne, campagne_compte_autorisations: { compte_id: compte.id }, privee: true
    return unless compte.validation_acceptee?

    can %i[read], Campagne, campagnes_publique_de_la_structure(compte)
    if compte.admin?
      can %i[read update autoriser_compte revoquer_compte destroy], Campagne,
          campagnes_de_la_structure(compte)
    end
  end

  def droit_evaluation(compte)
    can %i[read download_pdf], ActiveAdmin::Page, name: "Comparaison"
    cannot :create, Evaluation
    can :read, Evaluation, responsable_suivi_id: compte.id
    can %i[read destroy mise_en_action
           supprimer_responsable_suivi ajouter_responsable_suivi],
        Evaluation, campagne: { compte_id: compte.id }
    can %i[read mise_en_action
           supprimer_responsable_suivi ajouter_responsable_suivi],
        Evaluation, campagne: { campagne_compte_autorisations: { compte_id: compte.id } }
    return if compte.structure_id.blank?

    if compte.validation_acceptee?
      can %i[read mise_en_action supprimer_responsable_suivi
             ajouter_responsable_suivi renseigner_qualification],
          Evaluation,
          campagne: campagnes_publique_de_la_structure(compte)
    end

    if compte.admin?
      can %i[read update destroy], Evaluation,
          campagne: campagnes_de_la_structure(compte)
    end
  end

  def droit_beneficiaire(compte)
    cannot(:destroy, Beneficiaire)
    can :read, Beneficiaire, evaluations: { responsable_suivi_id: compte.id }
    can :read, Beneficiaire, evaluations: { campagne: { compte_id: compte.id } }
    can :read, Beneficiaire, evaluations: {
      campagne: { campagne_compte_autorisations: { compte_id: compte.id } }
    }
    droit_beneficiaire_admin if compte.au_moins_admin? && !compte.administratif?
    droit_beneficiaire_structure(compte) if compte.structure_id.present?
  end

  def droit_beneficiaire_admin
    can(:destroy, Beneficiaire) { |b| b.evaluations.empty? }
    can :fusionner, Beneficiaire
  end

  def droit_beneficiaire_structure(compte)
    if compte.validation_acceptee?
      can :read, Beneficiaire, evaluations: {
        campagne: campagnes_publique_de_la_structure(compte)
      }
    end

    if compte.admin?
      can :create, Beneficiaire unless compte.administratif?
      can %i[read update], Beneficiaire, evaluations: {
        campagne: campagnes_de_la_structure(compte)
      }
    end
  end

  def droit_evenement(compte)
    cannot %i[update create destroy], Evenement
  end

  def droit_restitution(compte)
    can :manage, Restitution::Base, campagne: { compte_id: compte.id }
    can :manage, Restitution::Base, campagne: campagnes_publique_de_la_structure(compte)
  end

  def droit_compte(compte)
    if compte.validation_acceptee?
      structure_ids = compte.admin? ? compte.structure.subtree_ids : compte.structure_id
      can :read, Compte, structure_id: structure_ids
    end
    can %i[read update], compte
    can :rejoindre_structure, compte
    can :accepter_cgu, compte
    comptes_generiques_ou_comptes_admin(compte)
    droits_validation_comptes(compte)
    cannot(:destroy, Compte) { |c| Campagne.exists?(compte: c) }
    cannot :update, compte if compte.email == Eva::EMAIL_DEMO
  end

  def droit_structure(compte)
    if compte.validation_acceptee?
      structure_ids = compte.admin? ? compte.structure.subtree_ids : compte.structure_id
      can :read, Structure, id: structure_ids
    end
    if compte.admin?
      structure_ids = compte.structure.subtree_ids
      can :update, Structure, id: structure_ids
    end
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
    can(%i[update], compte)
    cannot(:read, AnnonceGenerale)
    cannot(:read, SourceAide)
    cannot(:fusionner, Beneficiaire)
    cannot(%i[mise_en_action supprimer_responsable_suivi ajouter_responsable_suivi
              renseigner_qualification],
           Evaluation)
    cannot(%i[autoriser_compte revoquer_compte], Campagne)
  end

  def campagnes_de_la_structure(compte)
    { compte: { structure_id: compte.structure.subtree_ids } }
  end

  def campagnes_publique_de_la_structure(compte)
    { compte: { structure_id: compte.structure_id }, privee: false }
  end

  def comptes_generiques_ou_comptes_admin(compte)
    return unless compte.admin? || compte.compte_generique?

    structure_ids = compte.structure.subtree_ids
    can :create, Compte unless compte.administratif?
    can :update, Compte, structure_id: structure_ids
    can :edit_role, Compte, structure_id: structure_ids
    cannot :edit_role, compte if compte.compte_generique?
    can :destroy, Compte, structure_id: structure_ids, role: %i[conseiller]
  end

  def droits_validation_comptes(compte)
    if compte.au_moins_admin?
      structure_ids = compte.structure.subtree_ids
      can %i[autoriser refuser verifier], Compte, structure_id: structure_ids
    end
    cannot :refuser, Compte, &:au_moins_admin?
  end

  def can_create_campagne?(compte)
    compte.structure&.autorisation_creation_campagne || compte.admin? || compte.superadmin?
  end
end
