module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
        redirige_vers_nouveau_compte
      end

      # L'inscription se fait uniquement par inscription/nouveau_compte
      def create
        redirige_vers_nouveau_compte
      end

      private

      def redirige_vers_nouveau_compte
        redirect_to inscription_nouveau_compte_path(parametres_nouveau_compte), status: :see_other
      end

      def parametres_nouveau_compte
        if params[:invitation_token].present?
          { invitation_token: params[:invitation_token] }
        elsif params[:structure_id].present?
          { structure_id: params[:structure_id] }
        else
          {}
        end
      end
    end
  end
end
