class RenommeEvenementStopEnAbandon < ActiveRecord::Migration[6.0]
  class Evenement < ApplicationRecord; end

  def change
    Evenement.where(nom: 'stop').update_all(nom: 'abandon')
  end
end
