# frozen_string_literal: true

module ImportExport
  module Questionnaire
    class Import < ::ImportExport::ImportXls
      def initialize(headers)
        super(nil, headers)
      end

      def import_from_xls(file)
        recupere_data(file)
        valide_headers
        errors = importe_ligne(@data)
        raise Import::Error, errors.join("\n") if errors.any?
      end

      private

      def importe_ligne(data)
        data.each_with_index.with_object([]) do |(ligne, index), errors|
          next if ligne.compact.empty?

          begin
            ActiveRecord::Base.transaction { cree_ou_actualise_questionnaire(ligne) }
          rescue ActiveRecord::RecordInvalid => e
            errors << message_erreur_validation(e, index)
          end
        end
      end

      def cree_ou_actualise_questionnaire(ligne)
        questionnaire = ::Questionnaire.find_or_initialize_by(nom_technique: ligne[1])
        noms_techniques_ordonnes = ligne[2].split(",")
        questions = recupere_questions(noms_techniques_ordonnes)

        questionnaire.assign_attributes(
          libelle: ligne[0],
          questions: questions
        )
        questionnaire.save!
        questionnaire
      end

      def recupere_questions(noms_techniques_ordonnes)
        questions = Question.where(nom_technique: noms_techniques_ordonnes)
        questions.sort_by do |question|
          noms_techniques_ordonnes.index(question.nom_technique)
        end
      end
    end
  end
end
