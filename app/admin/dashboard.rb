require "addressable/uri"

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    if current_compte.utilisateur_entreprise?
      structure = current_compte.structure
      opco_financeur = structure&.opco_financeur

      render partial: "tableau_de_bord_eva_pro",
             locals: {
               campagnes: campagnes_entreprise,
               evaluations: evaluations_entreprise,
               actualites: actualites,
               opco: opco_financeur,
               structure: structure
             }
    else
      render partial: "tableau_de_bord_eva",
             locals: {
               evaluations: evaluations,
               actualites: actualites,
               campagnes: campagnes
             }
    end
  end

  controller do
    include EtapeInscriptionHelper
    before_action do
      flash.now[:annonce_generale] = "<span>#{annonce.texte}</span>".html_safe if annonce.present?
      message_incitation_compte_personnel
    end

    before_action :redirige_vers_inscription, :recupere_support, :recupere_evaluations,
                  :recupere_actualites, :recupere_campagnes, :recupere_prise_en_main,
                  :comptes_en_attente, :recupere_evaluations_sans_mise_en_action,
                  :recupere_donnees_entreprise

    private

    def redirige_vers_inscription
      return if current_compte.siret_pro_connect.blank?
      return if !current_compte.doit_completer_inscription?

      redirige_vers_etape_inscription(current_compte)
    end

    def annonce
      @annonce ||= AnnonceGenerale.order(created_at: :desc).find_by(afficher: true)
    end

    def message_incitation_compte_personnel
      return unless current_compte.compte_generique?

      lien = new_admin_compte_path(compte: { statut_validation: "acceptee" })
      flash.now[:compte_generique] =
        "<span>#{t('.incitation_creation_compte_personnel', lien: lien)}</span>".html_safe
    end

    def recupere_support
      @support = Compte.find_by(email: Eva::EMAIL_SUPPORT)
    end

    def recupere_evaluations
      @evaluations = Evaluation.tableau_de_bord(current_ability).includes(:beneficiaire).limit(10)
    end

    def recupere_evaluations_sans_mise_en_action
      @evaluations_sans_mise_en_action =
        Evaluation.tableau_de_bord_mises_en_action(current_ability).limit(6)
    end

    def recupere_actualites
      @actualites = Actualite.tableau_de_bord(current_ability).first(6)
    end

    def recupere_campagnes
      @campagnes = Campagne.accessible_by(current_ability).order(created_at: :desc).limit(10)
    end

    def recupere_prise_en_main
      @prise_en_main = PriseEnMain.new(
        compte: current_compte,
        nombre_campagnes: @campagnes.size,
        nombre_evaluations: @evaluations.size
      )
    end

    def comptes_en_attente
      @comptes_en_attente = Compte.where(
        statut_validation: :en_attente,
        structure_id: current_compte.structure_id
      )
    end

    def recupere_donnees_entreprise
      return unless current_compte.utilisateur_entreprise?

      @campagnes_entreprise = Campagne.accessible_by(current_ability)
                                    .order(created_at: :desc)
                                    .limit(10)
      @evaluations_entreprise = Evaluation.accessible_by(current_ability)
                                         .includes(:beneficiaire, :campagne)
                                         .order(created_at: :desc)
                                         .limit(10)
    end

    def campagnes_entreprise
      @campagnes_entreprise ||= []
    end

    def evaluations_entreprise
      @evaluations_entreprise ||= []
    end

    def opco_financeur
      return nil unless current_compte.structure.present?

      structure = current_compte.structure
      @opco_financeur ||= structure.opcos.find(&:financeur?) || structure.opcos.first
    end
  end
end
