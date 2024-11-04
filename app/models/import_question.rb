# frozen_string_literal: true

class ImportQuestion < ImportXls
  def initialize(question, headers_attendus)
    super
    @question = question
    @type = question.type
  end

  def cree_question
    ActiveRecord::Base.transaction do
      intialise_question
      cree_transcription(:intitule, @data[4], @data[3])
      cree_transcription(:modalite_reponse, @data[6], @data[5]) unless @question.sous_consigne?
      update_champs_specifiques
    end
    @question
  end

  def intialise_question
    @question.assign_attributes(libelle: @data[0],
                                nom_technique: @data[1], description: @data[7])
    attache_fichier(@question.illustration, @data[2])
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
    attache_fichier(@question.image_au_clic, @data[9])
    attache_fichier(@question.zone_cliquable, @data[8])
  end

  def update_glisser_deposer
    cree_reponses('reponse', method(:cree_reponse))
    attache_fichier(@question.zone_depot, @data[8])
  end

  def update_qcm
    @question.update!(type_qcm: @data[8])
    cree_reponses('choix', method(:cree_chaque_choix))
  end

  def update_saisie
    @question.update!(suffix_reponse: @data[8], reponse_placeholder: @data[9],
                      type_saisie: @data[10])
    cree_reponse_generique(@data[11], @data[12], 'bon')
  end

  def cree_reponses(type, creation_method)
    extrait_colonnes_reponses(type).each_value { |data| creation_method.call(data) }
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
        headers_data[item.to_i][data_type] = @data[index]
      end
    end
  end
end
