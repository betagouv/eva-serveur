module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
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

        @compte = Compte.new(compte_parametres_invitation)
        if enregistre_compte?
          @invitation.marquer_acceptee!(@compte)
          sign_in_et_redirige
        else
          self.resource = @compte
          render :new
        end
      end

      def create_sans_invitation
        @compte = Compte.new(compte_parametres)
        @compte.statut_validation = :en_attente
        @compte.assigne_role_admin_si_pas_d_admin
        if enregistre_compte?
          sign_in_et_redirige
        else
          render :new
        end
      end

      def compte_parametres_invitation
        compte_parametres.merge(
          structure_id: @invitation.structure_id,
          role: @invitation.role_pour_compte,
          statut_validation: statut_validation_pour_invitation
        )
      end

      def enregistre_compte?
        verify_recaptcha(model: @compte) && @compte.save
      end

      def sign_in_et_redirige
        sign_in @compte
        redirect_to admin_dashboard_path, notice: I18n.t("devise.registrations.signed_up")
      end

      def statut_validation_pour_invitation
        if @invitation.invitant.au_moins_admin?
          "acceptee"
        else
          "en_attente"
        end
      end
    end
  end
end
