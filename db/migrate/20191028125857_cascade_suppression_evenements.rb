class CascadeSuppressionEvenements < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key 'evenements', 'evaluations'
    add_foreign_key 'evenements', 'evaluations', on_delete: :cascade
  end
end
