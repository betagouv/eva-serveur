class SupprimeMessageQuestion < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :message
  end
end
