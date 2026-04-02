class Inscription::NouveauxComptesController < ApplicationController
  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    if params[:invitation_token].present?
      charge_invitation_ou_redirect
      return if performed?
    end

    if current_compte&.doit_completer_inscription?
      redirige_vers_etape_inscription(current_compte)
      return
    end

    if current_compte.present?
      redirect_to admin_dashboard_path
      return
    end

    @compte = Compte.new(email: @invitation&.email_destinataire)
  end

  def create
    if current_compte.present?
      redirect_to admin_dashboard_path
      return
    end

    if params[:invitation_token].present?
      create_avec_invitation
    else
      create_sans_invitation
    end
  end

  private

  def charge_invitation_ou_redirect
    @invitation = Invitation.find_by(token: params[:invitation_token])
    return if @invitation&.utilisable?

    redirect_to root_path,
                alert: I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee")
  end

  def create_sans_invitation
    @compte = Compte.new(compte_parametres.merge(role: :conseiller, statut_validation: :en_attente))
    @compte.assigne_preinscription
    if @compte.save
      sign_in(@compte)
      redirect_to inscription_informations_compte_path
    else
      render :show
    end
  end

  def create_avec_invitation
    @invitation = Invitation.find_by(token: params[:invitation_token])
    return redirect_si_invitation_invalide unless @invitation&.utilisable?

    traiter_resultat_creation_invitation(appelle_creation_compte_invitation)
  end

  def redirect_si_invitation_invalide
    redirect_to root_path,
                alert: I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee")
  end

  def appelle_creation_compte_invitation
    CreationCompteDepuisInvitationService.new(
      invitation: @invitation,
      parametres_compte: compte_parametres
    ).appeler
  end

  def traiter_resultat_creation_invitation(resultat)
    if resultat.succes
      sign_in(resultat.compte)
      redirect_to inscription_informations_compte_path
    else
      @compte = resultat.compte
      render :show
    end
  end

  def compte_parametres
    params.require(:compte).permit(
      :prenom,
      :nom,
      :telephone,
      :email,
      :password,
      :password_confirmation,
      :fonction,
      :service_departement,
      :cgu_acceptees
    )
  end
end
