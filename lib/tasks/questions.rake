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
    dossier_id = 'DOSSIER_ID'
    logger = RakeLogger.logger
    unless ENV.key?(dossier_id)
      logger.error "La variable d'environnement #{dossier_id} est manquante"
      logger.info 'Usage : rake questions:attache_assets DOSSIER_ID=<dossier_id>'
      next
    end

    begin
      GoogleDriveStorage.existe_dossier?(ENV.fetch(dossier_id, nil))
    rescue GoogleDriveStorage::Error => e
      logger.error e.message
      next
    end

    NOM_TECHNIQUES_QCM.each do |question_nom_technique, nom_illustration|
      question = Question.find_by(nom_technique: question_nom_technique)
      if question.blank?
        puts "Pas de question trouvée pour le nom_technique '#{question_nom_technique}'"
      end
      next if question.blank?

      recupere_fichier(ENV.fetch(dossier_id), question, "#{nom_illustration}.png")
      recupere_fichier(ENV.fetch(dossier_id), question, "#{question.nom_technique}.mp3",
                       question.transcription_intitule)
      attach_audio_choix(ENV.fetch(dossier_id), question)
    end
    puts 'Création des assets finie.'
  end
end

def recupere_fichier(dossier_id, question, fichier_path, model = nil)
  file = GoogleDriveStorage.recupere_fichier(dossier_id, fichier_path)
  if file
    file_content = file.download_to_string
    attach_file_to(model || question, file_content, fichier_path, question.nom_technique)
  else
    puts "Pas de fichier trouvé sur Google Drive pour '#{fichier_path}'"
  end
rescue GoogleDriveStorage::Error => e
  logger = RakeLogger.logger
  logger.error e.message
end

def attach_audio_choix(dossier_id, question)
  question.choix.each do |choix|
    recupere_fichier(dossier_id, question, "#{choix.nom_technique}.mp3", choix)
  end
end

def attach_file_to(instance, file_content, fichier_path, nom_technique)
  instance.send(attachment_type(fichier_path)).attach(
    io: StringIO.new(file_content),
    filename: fichier_path,
    content_type: content_type_for(fichier_path)
  )
  puts "#{attachment_type(fichier_path)} est rattaché à la question ##{nom_technique}"
end

def content_type_for(fichier_path)
  case fichier_path.split('.').last
  when 'mp3' then 'audio/mpeg'
  when 'png' then 'image/png'
  else 'application/octet-stream'
  end
end

def attachment_type(fichier_path)
  case fichier_path.split('.').last
  when 'mp3' then :audio
  when 'png' then :illustration
  else :autre
  end
end
