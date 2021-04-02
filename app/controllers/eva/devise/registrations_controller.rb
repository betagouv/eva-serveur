# frozen_string_literal: true

module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
        return redirect_to structures_path if params[:structure_id].blank?

        super do |resource|
          resource.structure = Structure.find_by id: params[:structure_id]
        end
      end
    end
  end
end
