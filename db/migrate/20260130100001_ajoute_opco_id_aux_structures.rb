# frozen_string_literal: true

class AjouteOpcoIdAuxStructures < ActiveRecord::Migration[7.2]
  def change
    add_reference :structures, :opco, type: :uuid, foreign_key: true, index: true
  end
end
