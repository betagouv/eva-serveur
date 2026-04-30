class Inscription::NouveauxComptesController < ApplicationController
  layout "inscription_v2"
  helper ::ActiveAdmin::ViewHelpers
  include EtapeInscriptionHelper

  def show
    if params[:invitation_token].present?
      charge_invitation_ou_redirect
      return if performed?
    end

    verifie_current_compte
    return if performed?

    @structure = Structure.find(params[:structure_id]) if params[:structure_id].present?
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

  def verifie_current_compte
    redirige_vers_etape_inscription(current_compte) if current_compte&.doit_completer_inscription?

    redirect_to admin_dashboard_path if current_compte.present?
  end

  def charge_invitation_ou_redirect
    @invitation = Invitation.find_by(token: params[:invitation_token])
    return redirect_to(inscription_invitation_invalide_path) unless @invitation&.utilisable?

    @structure = @invitation.structure
  end

  def create_sans_invitation
    @compte = Compte.new(compte_parametres.merge(role: :conseiller, statut_validation: :en_attente,
                                                 structure_id: params[:structure_id].presence))
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
    return redirect_to inscription_invitation_invalide_path unless @invitation&.utilisable?

    traiter_resultat_creation_invitation(appelle_creation_compte_invitation)
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
