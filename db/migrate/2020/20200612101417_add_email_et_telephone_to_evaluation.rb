class AddEmailEtTelephoneToEvaluation < ActiveRecord::Migration[6.0]
  def change
    add_column :evaluations, :email, :string
    add_column :evaluations, :telephone, :string
  end
end
