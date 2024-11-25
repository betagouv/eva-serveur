class RenomeNomTechniqueQuestionQcm < ActiveRecord::Migration[7.0]
  class Question < ApplicationRecord
    CATEGORIE = %i[situation scolarite sante appareils].freeze
    attribute :categorie, :string
    enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true
  end

  class QuestionQcm < Question; end
  class QuestionSaisie < Question; end
  def up
    QuestionQcm.where(nom_technique: 'niveau_etude').update(nom_technique: 'dernier_niveau_etude')
    QuestionSaisie.where(nom_technique: 'quel_age').update(nom_technique: 'age')
  end
  def down
    QuestionQcm.where(nom_technique: 'dernier_niveau_etude').update(nom_technique: 'niveau_etude')
    QuestionSaisie.where(nom_technique: 'age').update(nom_technique: 'quel_age')
  end
end
