# frozen_string_literal: true

module Restitution
  class Bienvenue < Base
    def questions_reponses
      @questions_reponses ||= QuestionsReponses.new(evenements)
    end

    def questions_et_reponses(type_qcm = nil)
      questions_reponses.questions_et_reponses(type_qcm)
    end

    def verifie_reponse(question, reponse)
      if question.type_saisie == 'numerique'
        i = reponse.to_i
        return i < 2**31 ? i : nil
      end

      reponse.respond_to?(:nom_technique) ? reponse.nom_technique : reponse
    end

    def attributs_sociodemographiques
      questions_et_reponses.each_with_object({}) do |q_et_r, attributs|
        question = q_et_r.first
        reponse = q_et_r.last
        next unless question.categorie_situation? ||
                    question.categorie_scolarite?

        attributs[question.nom_technique] = verifie_reponse(question, reponse)
      end
    end

    def persiste
      super
      donnees = DonneeSociodemographique.with_deleted
                                        .find_or_create_by(evaluation: partie.evaluation)
      donnees.update(attributs_sociodemographiques.merge(deleted_at: nil))
    end

    def inclus_autopositionnement?
      [Questionnaire::SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT,
       Questionnaire::AUTOPOSITIONNEMENT].include?(questionnaire)
    end

    def questionnaires_questions_pour(categorie)
      campagne.questionnaire_pour(situation)
              .questionnaires_questions
              .joins(:question)
              .where(questions: { categorie: categorie })
    end

    private

    def questionnaire
      @questionnaire ||= campagne.questionnaire_pour(situation)&.nom_technique
    end
  end
end
