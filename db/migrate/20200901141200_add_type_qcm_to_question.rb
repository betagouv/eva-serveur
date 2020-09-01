class AddTypeQcmToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :questions, :type_qcm, :integer, default: 0
  end
end
