# frozen_string_literal: true

require 'rake_logger'
require 'google_drive_storage'

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

NOM_TECHNIQUES_CONSIGNES = {
  sous_consigne_LOdi_1: 'programme_tele',
  sous_consigne_LOdi_2: 'programme_tele_zoom',
  sous_consigne_ALrd_1: 'terrasse_cafe',
  sous_consigne_ALrd_2: 'liste_titres_musique',
  sous_consigne_ACrd_1: 'magazine_sans_texte',
  sous_consigne_ACrd_2: 'magazine_sans_texte',
  sous_consigne_APlc_1: 'terrasse_cafe',
  sous_consigne_APlc_2: 'telephone_liste_de_courses',
  sous_consigne_HPar_1: 'hpar_c1',
  sous_consigne_HGac_1: 'graphique_avec_selection',
  sous_consigne_HCvf_1: 'rubrique_environnement',
  sous_consigne_HPfb_1: 'terrasse_cafe',
  sous_consigne_HPfb_2: 'telephone_email'
}.freeze
# rubocop:enable Naming/VariableNumber

DOSSIER_ID = 'DOSSIER_ID'
TYPE_QUESTION = 'TYPE_QUESTION'

namespace :questions do
  desc 'Attache les assets de cafe de la place aux instances de Question correpondantes'
  task attache_assets: :environment do
    logger = RakeLogger.logger
    unless ENV.key?(DOSSIER_ID)
      logger.error "La variable d'environnement #{DOSSIER_ID} est manquante"
      logger.info 'Usage : rake questions:attache_assets DOSSIER_ID=<dossier_id>'
      next
    end

    @drive = GoogleDriveStorage.new
    begin
      @drive.existe_dossier?(ENV.fetch(DOSSIER_ID, nil))
    rescue GoogleDriveStorage::Error => e
      logger.error e.message
      next
    end

    case ENV.fetch(TYPE_QUESTION, nil)
    when 'QCM'
      attache_assets(NOM_TECHNIQUES_QCM)
    when 'SOUS_CONSIGNE'
      attache_assets(NOM_TECHNIQUES_CONSIGNES)
    end
  end
end

def attache_assets(nom_techniques)
  nom_techniques.each do |question_nom_technique, nom_illustration|
    question = Question.find_by(nom_technique: question_nom_technique)
    if question
      recupere_fichier(question, "#{nom_illustration}.png")
      recupere_fichier(question, "#{question.nom_technique}.mp3", question.transcription_intitule)
      attach_audio_choix(question) if nom_techniques == NOM_TECHNIQUES_QCM
    else
      puts "Pas de question trouvée pour le nom_technique '#{question_nom_technique}'"
    end
  end
end

def recupere_fichier(question, fichier_path, model = nil)
  file = @drive.recupere_fichier(ENV.fetch(DOSSIER_ID, nil), fichier_path)
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

def attach_audio_choix(question)
  question.choix.each do |choix|
    recupere_fichier(question, "#{choix.nom_technique}.mp3", choix)
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
