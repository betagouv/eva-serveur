class UpdateTousLesComptesExistants < ActiveRecord::Migration[6.1]
  def up
    Compte.update_all(confirmed_at: DateTime.now)
  end

  def down
    Compte.update_all(confirmed_at: nil)
  end
end
