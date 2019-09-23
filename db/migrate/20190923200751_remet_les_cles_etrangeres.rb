class RemetLesClesEtrangeres < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key 'campagnes', 'comptes'
    add_foreign_key 'campagnes', 'questionnaires'
    add_foreign_key 'choix', 'questions'
    add_foreign_key 'evaluations', 'campagnes'
    add_foreign_key 'evenements', 'evaluations'
    add_foreign_key 'evenements', 'situations'
    add_foreign_key 'questionnaires_questions', 'questionnaires'
    add_foreign_key 'questionnaires_questions', 'questions'
    add_foreign_key 'situations_configurations', 'campagnes'
  end
end
