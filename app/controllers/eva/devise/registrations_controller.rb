# frozen_string_literal: true

module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
        structure = Structure.find_by id: params[:structure_id]
        return redirect_to structures_path unless structure

        super do |resource|
          resource.structure = structure
        end
      end

      def create
        @compte = Compte.new compte_parametres
        @compte.assigne_role_admin_si_pas_d_admin
        if verify_recaptcha(model: @compte) && @compte.save
          sign_in @compte
          redirect_to admin_dashboard_path, notice: I18n.t("devise.registrations.signed_up")
        else
          render :new
        end
      end

      def compte_parametres
        params.require(:compte).permit!.to_h
      end
    end
  end
end
