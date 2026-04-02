module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
        if params[:invitation_token].present?
          redirect_to inscription_nouveau_compte_path(invitation_token: params[:invitation_token]),
                      status: :see_other
          return
        end

        structure = structure_pour_inscription
        return if performed?
        return redirect_to structures_path unless structure

        super { |resource| resource.structure = structure }
      end

      def create
        if params[:invitation_token].present?
          create_avec_invitation
        else
          create_sans_invitation
        end
      end

      def compte_parametres
        params.require(:compte).permit!.to_h
      end

      private

      def structure_pour_inscription
        if params[:invitation_token].present?
          charge_et_valide_invitation
          return if performed?

          @invitation.structure
        else
          Structure.find_by(id: params[:structure_id])
        end
      end

      def charge_et_valide_invitation
        @invitation = Invitation.find_by(token: params[:invitation_token])
        return if @invitation&.utilisable?

        redirect_to structures_path,
                    alert: I18n.t("devise.registrations.invitation_invalide_ou_deja_utilisee")
      end

      def create_avec_invitation
        charge_et_valide_invitation
        return if performed?

        resultat = CreationCompteDepuisInvitationService.new(
          invitation: @invitation,
          parametres_compte: compte_parametres
        ).appeler

        if resultat.succes
          @compte = resultat.compte
          sign_in_et_redirige_inscription
        else
          self.resource = resultat.compte
          render :new
        end
      end

      def create_sans_invitation
        @compte = Compte.new(compte_parametres)
        @compte.assigne_role_admin_si_pas_d_admin
        if enregistre_compte?
          sign_in_et_redirige
        else
          render :new
        end
      end

      def enregistre_compte?
        verify_recaptcha(model: @compte) && @compte.save
      end

      def sign_in_et_redirige
        sign_in @compte
        redirect_to admin_dashboard_path, notice: I18n.t("devise.registrations.signed_up")
      end

      def sign_in_et_redirige_inscription
        sign_in @compte
        redirect_to inscription_informations_compte_path,
                    notice: I18n.t("devise.registrations.signed_up")
      end
    end
  end
end
