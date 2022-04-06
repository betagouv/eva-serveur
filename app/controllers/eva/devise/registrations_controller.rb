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

      def build_resource(hash = {})
        super(hash)
        resource.assigne_role_admin_si_pas_d_admin
      end
    end
  end
end
