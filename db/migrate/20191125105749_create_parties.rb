class CreateParties < ActiveRecord::Migration[6.0]
  def change
    create_table :parties, id: :uuid do |t|
      t.string :session_id
      t.jsonb  :metriques

      t.timestamps
    end

    add_reference :parties, :evaluation, foreign_key: true, type: :uuid
  end
end
