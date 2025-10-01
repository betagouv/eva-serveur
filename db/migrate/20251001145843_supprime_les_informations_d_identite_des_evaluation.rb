class SupprimeLesInformationsDIdentiteDesEvaluation < ActiveRecord::Migration[7.2]
  def change
    remove_column :evaluations, :email, :string
    remove_column :evaluations, :telephone, :string
    remove_column :evaluations, :anonymise_le, :datetime
  end
end
