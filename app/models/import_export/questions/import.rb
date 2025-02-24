# frozen_string_literal: true

module ImportExport
  module Questions
    class Import < ::ImportExport::ImportXls
      def initialize(type, headers_attendus)
        super
        @type = type
        @headers = headers_attendus
      end

      def import_from_xls(file)
        recupere_data(file)
        valide_headers
        errors = process_rows(@data)
        raise Import::Error, errors.join("\n") if errors.any?
      end

      private

      def process_rows(data)
        data.each_with_index.with_object([]) do |(row, index), errors|
          next if row.compact.empty?

          begin
            @row = row
            cree_ou_actualise_question
          rescue ActiveRecord::RecordInvalid => e
            errors << message_erreur_validation(e, index)
          end
        end
      end

      def message_erreur_validation(exception, index)
        I18n.t('.layouts.erreurs.import_question.ligne',
               numero: index,
               message: exception.record.errors.full_messages.to_sentence)
      end

      def cree_ou_actualise_question
        ActiveRecord::Base.transaction do
          col = 0
          question = @type.constantize.find_or_create_by(nom_technique: @row[col += 1])
          actualise_libelle(question)
          attache_fichier(question.illustration, @row[col += 1], "#{@row[1]}_illustration")
          cree_transcription(question.id, :intitule, @row[col += 1], @row[col += 1],
                             "#{@row[1]}_intitule")
          update_champs_specifiques(question, col)
        end
      end

      def actualise_libelle(question)
        question.update!(libelle: @row[0])
      end

      def initialise_modalite_reponse(question, col)
        cree_transcription(question.id, :modalite_reponse, @row[col += 1], @row[col += 1],
                           "#{@row[1]}_modalite_reponse")
        question.update!(description: @row[col += 1],
                         demarrage_audio_modalite_reponse: @row[col += 1])
        col
      end

      def cree_transcription(question_id, categorie, ecrit, audio_url, nom_technique)
        t = Transcription.where(question_id: question_id, categorie: categorie).first_or_initialize
        t.assign_attributes(ecrit: ecrit)
        t.save!
        attache_fichier(t.audio, audio_url, nom_technique)
      end

      def update_champs_specifiques(question, col); end

      def cree_reponses(type)
        extrait_colonnes_reponses(type).each_value do |data|
          next if data.values.all?(&:nil?) ## si une ligne de réponse est vide on la saute

          yield(data)
        end
      end

      def cree_reponse_generique(question_id:, intitule:, nom_technique:, type_choix:,
                                 position_client: nil)
        choix = Choix.where(nom_technique: nom_technique).first_or_initialize
        choix.assign_attributes(intitule: intitule, question_id: question_id,
                                type_choix: type_choix, position_client: position_client)
        choix.save!
        choix
      end

      def extrait_colonnes_reponses(type)
        @headers.each_with_index.with_object({}) do |(header, index), headers_data|
          next unless (match = header.to_s.match(/#{type}_(\d+)_(.*)/))

          item, data_type = match.captures
          headers_data[item.to_i] ||= {}
          headers_data[item.to_i][data_type] = @row[index]
        end
      end
    end
  end
end
