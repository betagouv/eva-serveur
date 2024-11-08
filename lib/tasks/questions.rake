# frozen_string_literal: true

require 'rake_logger'

# rubocop:disable Naming/VariableNumber
NOM_TECHNIQUES_QCM = {
  lodi_1: 'programme_tele',
  lodi_2: 'programme_tele_cirque',
  lodi_3: 'programme_tele_18h55',
  lodi_4: 'programme_tele_18h55',
  lodi_5: 'programme_tele_18h55',
  lodi_6: 'programme_tele_zoom',
  lodi_7: 'programme_tele_zoom',
  lodi_8: 'programme_tele_zoom',
  lodi_9: 'programme_tele_zoom',
  lodi_10: 'programme_tele_zoom',
  lodi_11: 'programme_tele_zoom',
  lodi_12: 'programme_tele_zoom',
  lodi_13: 'programme_tele_zoom',
  titre_1: 'liste_titres_musique',
  titre_2: 'liste_titres_musique',
  titre_10: 'liste_titres_musique',
  titre_3: 'liste_titres_musique',
  titre_11: 'liste_titres_musique',
  titre_6: 'liste_titres_musique',
  titre_8: 'liste_titres_musique',
  titre_5: 'liste_titres_musique',
  titre_4: 'liste_titres_musique',
  titre_7: 'liste_titres_musique',
  acrd_6: 'magazine_sans_texte',
  acrd_7: 'magazine_sans_texte',
  acrd_8: 'magazine_sans_texte',
  acrd_9: 'magazine_sans_texte',
  acrd_10: 'magazine_sans_texte',
  hpar_2: 'journal_avec_nouvelle',
  hpar_3: 'journal_avec_nouvelle_zoom',
  hcvf_3: 'rubrique_environnement',
  hcvf_4: 'rubrique_environnement'
}.freeze
# rubocop:enable Naming/VariableNumber

namespace :questions do
  desc 'Attache les assets de cafe de la place aux instances de Question correpondantes'
  task attache_assets: :environment do
    NOM_TECHNIQUES_QCM.each do |nom_technique_qcm, nom_illustration|
      question = Question.find_by(nom_technique: nom_technique_qcm)
      puts "Pas de question trouvée pour le nom_technique '#{nom_technique_qcm}'" unless question
      next unless question

      attache_illustration(question, nom_technique_qcm, nom_illustration)
      attach_audio_intitule(question, nom_technique_qcm)
      attach_audio_choix(question, nom_technique_qcm)
    end
    puts 'Création des assets finie.'
  end
end

def attache_illustration(question, nom_technique_qcm, nom_illustration)
  chemin = chemin_du_fichier(nom_illustration, 'images', 'png')
  attach_file_to_question(question, chemin, :illustration, nom_technique_qcm)
end

def attach_audio_intitule(question, nom_technique_qcm)
  chemin = chemin_du_fichier(nom_technique_qcm, 'audio_questions', 'mp3')
  attach_file_to_question(question.transcription_intitule, chemin, :audio,
                          nom_technique_qcm)
end

def attach_audio_choix(question, nom_technique_qcm)
  question.choix.each do |choix|
    chemin = chemin_du_fichier(choix.nom_technique, 'audio_reponses', 'mp3')
    attach_file_to_question(choix, chemin, :audio, nom_technique_qcm)
  end
end

def attach_file_to_question(instance, chemin_du_fichier, attachment_type, nom_technique_qcm)
  instance.send(attachment_type).attach(
    io: File.open(chemin_du_fichier),
    filename: File.basename(chemin_du_fichier),
    content_type: content_type_for(chemin_du_fichier)
  )
  puts "#{File.basename(chemin_du_fichier)} est rattaché à la question ##{nom_technique_qcm}"
end

def content_type_for(chemin_du_fichier)
  case File.extname(chemin_du_fichier)
  when '.mp3' then 'audio/mpeg'
  when '.png' then 'image/png'
  else 'application/octet-stream'
  end
end

def chemin_du_fichier(nom_fichier, folder, extension)
  Rails.root.join("app/assets/cafe_de_la_place/#{folder}/#{nom_fichier}.#{extension}")
end
