# frozen_string_literal: true

class AjouteUrlOffreServicesAOpcos < ActiveRecord::Migration[7.0]
  def change
    add_column :opcos, :url_offre_services, :string
  end
end
