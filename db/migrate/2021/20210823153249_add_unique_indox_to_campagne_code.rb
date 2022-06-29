class AddUniqueIndoxToCampagneCode < ActiveRecord::Migration[6.1]
  def change
    add_index :campagnes, :code, unique: true
  end
end
