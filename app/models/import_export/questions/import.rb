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
            cree_question
          rescue ActiveRecord::RecordInvalid => e
            errors << message_erreur_validation(e, index)
          end
        end
      end

      # rubocop:disable Metrics/AbcSize
      def cree_question
        @question = Question.new(type: @type) # On crée une nouvelle instance pour chaque ligne
        @question.assign_attributes(libelle: @row[0], nom_technique: @row[1], description: @row[7])
        attache_fichier(@question.illustration, @row[2])
        @question.save!
        cree_transcription(:intitule, @row[4], @row[3])
        cree_transcription(:modalite_reponse, @row[6], @row[5]) unless @question.sous_consigne?
        update_champs_specifiques
        @question
      end
      # rubocop:enable Metrics/AbcSize

      def intialise_question
        @question.assign_attributes(libelle: @row[0],
                                    nom_technique: @row[1], description: @row[7])
        attache_fichier(@question.illustration, @row[2])
        @question.save!
      end

      def cree_transcription(categorie, audio_url, ecrit)
        t = Transcription.create!(ecrit: ecrit, question_id: @question.id, categorie: categorie)
        attache_fichier(t.audio, audio_url)
      end

      def update_champs_specifiques
        updates = {
          'QuestionClicDansImage' => :update_clic_dans_image,
          'QuestionGlisserDeposer' => :update_glisser_deposer,
          'QuestionQcm' => :update_qcm,
          'QuestionSaisie' => :update_saisie
        }
        send(updates[@type]) if updates.key?(@type)
      end

      def update_clic_dans_image
        attache_fichier(@question.image_au_clic, @row[9])
        attache_fichier(@question.zone_cliquable, @row[8])
      end

      def update_glisser_deposer
        cree_reponses('reponse', method(:cree_reponse))
        attache_fichier(@question.zone_depot, @row[8])
      end

      def update_qcm
        @question.update!(type_qcm: @row[8])
        cree_reponses('choix', method(:cree_chaque_choix))
      end

      def update_saisie
        @question.update!(suffix_reponse: @row[8], reponse_placeholder: @row[9],
                          type_saisie: @row[10])
        cree_reponse_generique(@row[11], @row[12], 'bon')
      end

      def cree_reponses(type, creation_method)
        extrait_colonnes_reponses(type).each_value do |data|
          creation_method.call(data)
        end
      end

      def cree_chaque_choix(data)
        choix = cree_reponse_generique(data['intitule'], data['nom_technique'], data['type_choix'])
        attache_fichier(choix.audio, data['audio'])
      end

      def cree_reponse(data)
        reponse = cree_reponse_generique(nil, data['nom_technique'], data['type_choix'],
                                         data['position_client'])
        attache_fichier(reponse.illustration, data['illustration'])
      end

      def cree_reponse_generique(intitule, nom_technique, type_choix, position_client = nil)
        Choix.create!(intitule: intitule, nom_technique: nom_technique,
                      question_id: @question.id, type_choix: type_choix,
                      position_client: position_client)
      end

      def extrait_colonnes_reponses(reponse)
        @headers.each_with_index.with_object({}) do |(header, index), headers_data|
          if (match = header.to_s.match(/#{reponse}_(\d+)_(.*)/))
            item, data_type = match.captures
            headers_data[item.to_i] ||= {}
            headers_data[item.to_i][data_type] = @row[index]
          end
        end
      end
    end
  end
end
