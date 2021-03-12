# frozen_string_literal: true

module Eva
  module Devise
    class RegistrationsController < ActiveAdmin::Devise::RegistrationsController
      def new
        super do |resource|
          resource.structure = Structure.find_by id: params[:structure_id]
        end
      end
    end
  end
end
