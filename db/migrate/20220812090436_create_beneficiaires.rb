class CreateBeneficiaires < ActiveRecord::Migration[7.0]
  def change
    create_table :beneficiaires, id: :uuid do |t|
      t.string :nom

      t.timestamps
    end
  end
end
