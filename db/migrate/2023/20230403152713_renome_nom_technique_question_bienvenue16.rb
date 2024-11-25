class RenomeNomTechniqueQuestionBienvenue16 < ActiveRecord::Migration[7.0]
  class Question < ApplicationRecord
    CATEGORIE = %i[situation scolarite sante appareils].freeze
    attribute :categorie, :string
    enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true
  end

  class QuestionQcm < Question; end

  def up
    bienvenue_16 = QuestionQcm.find_by(nom_technique: 'bienvenue_16')
    return unless bienvenue_16.present?

    question = QuestionQcm.find_by(nom_technique: 'lieu_scolarite')
    if question.present?
      QuestionnaireQuestion.where(question: question).update(question_id: bienvenue_16.id)
      question.really_destroy!
    end

    bienvenue_16.update(nom_technique: 'lieu_scolarite')
    Choix
      .where(question_id: bienvenue_16.id, nom_technique: 'bienvenue_16_reponse_1')
      .update(nom_technique: 'france')
    Choix
      .where(question_id: bienvenue_16.id, nom_technique: 'bienvenue_16_reponse_2')
      .update(nom_technique: 'etranger')
    Choix
      .where(question_id: bienvenue_16.id, nom_technique: 'bienvenue_non')
      .update(nom_technique: 'non')
  end

  def down
    bienvenue_16 = QuestionQcm.find_by(nom_technique: 'lieu_scolarite')
    if bienvenue_16.present?
      bienvenue_16.update(nom_technique: 'bienvenue_16')
      Choix
        .where(question_id: bienvenue_16.id, nom_technique: 'france')
        .update(nom_technique: 'bienvenue_16_reponse_1')
      Choix
        .where(question_id: bienvenue_16.id, nom_technique: 'etranger')
        .update(nom_technique: 'bienvenue_16_reponse_2')
      Choix
        .where(question_id: bienvenue_16.id, nom_technique: 'non')
        .update(nom_technique: 'bienvenue_16_reponse_3')
    end
  end
end
