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
        errors = importe_ligne(@data)
        raise Import::Error, errors.join("\n") if errors.any?
      end

      private

      def importe_ligne(data)
        data.each_with_index.with_object([]) do |(ligne, index), errors|
          next if ligne.compact.empty?

          begin
            cellules = IterateurCellules.new(ligne)
            ActiveRecord::Base.transaction { cree_ou_actualise_question(cellules) }
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

      def cree_ou_actualise_question(cellules)
        cellules.suivant # saute la première colonne
        question = @type.constantize.find_or_create_by(nom_technique: cellules.suivant)
        actualise_libelle(question, cellules)
        attache_fichier(question.illustration, cellules.suivant, "#{cellules.cell(1)}_illustration")
        cree_transcription(question.id, :intitule, cellules.suivant, cellules.suivant,
                           "#{cellules.cell(1)}_intitule")
        question
      end

      def actualise_libelle(question, cellules)
        question.update!(libelle: cellules.cell(0))
      end

      def cree_transcription(question_id, categorie, ecrit, audio_url, nom_technique)
        t = Transcription.where(question_id: question_id, categorie: categorie).first_or_initialize
        t.assign_attributes(ecrit: ecrit)
        t.save!
        attache_fichier(t.audio, audio_url, nom_technique)
      end

      def update_champs_specifiques(question, col); end

      def cree_reponses(type, cellules)
        extrait_colonnes_reponses(type, cellules).each_value do |data|
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

      def extrait_colonnes_reponses(type, cellules)
        @headers.each_with_index.with_object({}) do |(header, index), headers_data|
          next unless (match = header.to_s.match(/#{type}_(\d+)_(.*)/))

          item, data_type = match.captures
          headers_data[item.to_i] ||= {}
          headers_data[item.to_i][data_type] = cellules.cell(index)
        end
      end
    end
  end
end
