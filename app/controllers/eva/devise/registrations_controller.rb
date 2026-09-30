module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      # L'inscription se fait uniquement par inscription/nouveau_compte
      def new
        redirect_to inscription_nouveau_compte_path(parametres_nouveau_compte), status: :see_other
      end

      private

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
