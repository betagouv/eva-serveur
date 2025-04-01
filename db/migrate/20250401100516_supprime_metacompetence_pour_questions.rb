class SupprimeMetacompetencePourQuestions < ActiveRecord::Migration[7.2]
  def change
    remove_column :questions, :metacompetence, :string
  end
end
