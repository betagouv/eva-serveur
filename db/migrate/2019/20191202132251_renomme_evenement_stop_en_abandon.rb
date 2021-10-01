class RenommeEvenementStopEnAbandon < ActiveRecord::Migration[6.0]
  def change
    Evenement.where(nom: 'stop').update_all(nom: 'abandon')
  end
end
