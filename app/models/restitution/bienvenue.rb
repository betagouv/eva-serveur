# frozen_string_literal: true

module Restitution
  class Bienvenue < Base
    def questions_reponses
      @questions_reponses ||= QuestionsReponses.new(evenements)
    end

    def questions_et_reponses(type_qcm = nil)
      questions_reponses.questions_et_reponses(type_qcm)
    end

    def attributs_sociodemographiques
      categorie_scolarite = I18n.t('admin.evaluations.autopositionnement_scolarite.titre')
      categorie_situation = I18n.t('admin.evaluations.autopositionnement_situation.titre')
      questions_et_reponses.each_with_object({}) do |q_et_r, attributs|
        question = q_et_r.first
        reponse = q_et_r.last
        next unless question.libelle.start_with?(categorie_scolarite) ||
                    question.libelle.start_with?(categorie_situation)

        attributs[question.nom_technique] =
          reponse.respond_to?(:nom_technique) ? reponse.nom_technique : reponse
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

    private

    def questionnaire
      @questionnaire ||= campagne.questionnaire_pour(situation)&.nom_technique
    end
  end
end
