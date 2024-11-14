# frozen_string_literal: true

require 'rake_logger'
require 'google_drive_storage'

module ConstantesQuestions
  unless const_defined?(:NOM_TECHNIQUES_QCM)
    NOM_TECHNIQUES_QCM = [
      %w[lodi_1 programme_tele],
      %w[lodi_2 programme_tele_cirque],
      %w[lodi_3 programme_tele_18h55],
      %w[lodi_4 programme_tele_18h55],
      %w[lodi_5 programme_tele_18h55],
      %w[lodi_6 programme_tele_zoom],
      %w[lodi_7 programme_tele_zoom],
      %w[lodi_8 programme_tele_zoom],
      %w[lodi_9 programme_tele_zoom],
      %w[lodi_10 programme_tele_zoom],
      %w[lodi_11 programme_tele_zoom],
      %w[lodi_12 programme_tele_zoom],
      %w[lodi_13 programme_tele_zoom],
      %w[titre_1 liste_titres_musique],
      %w[titre_2 liste_titres_musique],
      %w[titre_10 liste_titres_musique],
      %w[titre_3 liste_titres_musique],
      %w[titre_11 liste_titres_musique],
      %w[titre_6 liste_titres_musique],
      %w[titre_8 liste_titres_musique],
      %w[titre_5 liste_titres_musique],
      %w[titre_4 liste_titres_musique],
      %w[titre_7 liste_titres_musique],
      %w[acrd_6 magazine_sans_texte],
      %w[acrd_7 magazine_sans_texte],
      %w[acrd_8 magazine_sans_texte],
      %w[acrd_9 magazine_sans_texte],
      %w[acrd_10 magazine_sans_texte],
      %w[hpar_2 journal_avec_nouvelle],
      %w[hpar_3 journal_avec_nouvelle_zoom],
      %w[hcvf_3 rubrique_environnement],
      %w[hcvf_4 rubrique_environnement]
    ].freeze
  end

  unless const_defined?(:NOM_TECHNIQUES_CONSIGNES)
    NOM_TECHNIQUES_CONSIGNES = [
      %w[sous_consigne_LOdi_1 programme_tele],
      %w[sous_consigne_LOdi_2 programme_tele_zoom],
      %w[sous_consigne_ALrd_1 terrasse_cafe],
      %w[sous_consigne_ALrd_2 liste_titres_musique],
      %w[sous_consigne_ACrd_1 magazine_sans_texte],
      %w[sous_consigne_ACrd_2 magazine_sans_texte],
      %w[sous_consigne_APlc_1 terrasse_cafe],
      %w[sous_consigne_APlc_2 telephone_liste_de_courses],
      %w[sous_consigne_HPar_1 hpar_c1],
      %w[sous_consigne_HGac_1 graphique_avec_selection],
      %w[sous_consigne_HCvf_1 rubrique_environnement],
      %w[sous_consigne_HPfb_1 terrasse_cafe],
      %w[sous_consigne_HPfb_2 telephone_email]
    ].freeze
  end

  unless const_defined?(:NOM_TECHNIQUES_GLISSER_DEPOSER)
    NOM_TECHNIQUES_GLISSER_DEPOSER = [
      hpar_1: 'journal_vide'
    ].freeze
  end

  unless const_defined?(:NOM_TECHNIQUES_SAISIE)
    NOM_TECHNIQUES_SAISIE = [
      aplc_1: 'liste_de_course',
      aplc_2: 'liste_de_course',
      aplc_3: 'liste_de_course',
      aplc_4: 'liste_de_course',
      aplc_5: 'liste_de_course',
      aplc_6: 'liste_de_course',
      aplc_7: 'liste_de_course',
      aplc_8: 'liste_de_course',
      aplc_9: 'liste_de_course',
      aplc_10: 'liste_de_course',
      aplc_11: 'liste_de_course',
      aplc_12: 'liste_de_course',
      aplc_13: 'liste_de_course',
      aplc_14: 'liste_de_course',
      aplc_15: 'liste_de_course',
      aplc_16: 'liste_de_course',
      aplc_17: 'liste_de_course',
      aplc_18: 'liste_de_course',
      aplc_19: 'liste_de_course',
      aplc_20: 'liste_de_course',
      hpfb_1: 'telephone_email',
      hpfb_2: 'telephone_email',
      hpfb_3: 'telephone_email',
      hpfb_4: 'telephone_email',
      hpfb_5: 'telephone_email',
      hpfb_6: 'telephone_email',
      hpfb_7: 'telephone_email',
      hpfb_8: 'telephone_email',
      hpfb_9: 'telephone_email',
      hpfb_10: 'telephone_email',
      hpfb_11: 'telephone_email',
      hpfb_12: 'telephone_email',
      hpfb_13: 'telephone_email',
      hpfb_14: 'telephone_email',
      hpfb_15: 'telephone_email',
      hpfb_16: 'telephone_email',
      hpfb_17: 'telephone_email',
      hpfb_18: 'telephone_email',
      hpfb_19: 'telephone_email',
      hpfb_20: 'telephone_email'
    ].freeze
  end

  DOSSIER_ID = 'DOSSIER_ID' unless const_defined?(:DOSSIER_ID)
  TYPE_QUESTION = 'TYPE_QUESTION' unless const_defined?(:TYPE_QUESTION)
end

namespace :questions do
  desc 'Attache les assets de cafe de la place aux instances de Question correpondantes'
  task attache_assets: :environment do
    @logger = RakeLogger.logger

    unless parametre_present?(ConstantesQuestions::DOSSIER_ID) &&
           parametre_present?(ConstantesQuestions::TYPE_QUESTION)
      next
    end

    @drive = GoogleDriveStorage.new
    begin
      @drive.existe_dossier?(ENV.fetch(ConstantesQuestions::DOSSIER_ID, nil))
    rescue GoogleDriveStorage::Error => e
      @logger.error e.message
      next
    end

    case ENV.fetch(ConstantesQuestions::TYPE_QUESTION, nil)
    when 'QCM'
      attache_assets(ConstantesQuestions::NOM_TECHNIQUES_QCM)
    when 'SOUS_CONSIGNE'
      attache_assets(ConstantesQuestions::NOM_TECHNIQUES_CONSIGNES)
    when 'GLISSER_DEPOSER'
      attache_assets(ConstantesQuestions::NOM_TECHNIQUES_GLISSER_DEPOSER)
    when 'SAISIE'
      attache_assets(ConstantesQuestions::NOM_TECHNIQUES_SAISIE)
    end
  end
end

def parametre_present?(variable)
  return true if ENV.key?(variable)

  @logger.error "La variable d'environnement #{variable} est manquante"
  @logger.info 'Usage : rake questions:attache_assets ' \
               'DOSSIER_ID=<dossier_id> TYPE_QUESTION=<TYPE_QUESTION>'
end

def attache_assets(nom_techniques)
  nom_techniques.each do |question_nom_technique, nom_illustration|
    question = Question.find_by(nom_technique: question_nom_technique)
    next unless question

    recupere_fichier(question, "#{nom_illustration}.png")
    recupere_fichier(question, "#{question.nom_technique}.mp3", question.transcription_intitule)
    attach_audio_choix(question) if question.qcm?
    attach_images_reponses(question) if question.glisser_deposer?
  end
end

def recupere_fichier(question, fichier_path, model = nil)
  file = @drive.recupere_fichier(ENV.fetch(ConstantesQuestions::DOSSIER_ID, nil), fichier_path)
  if file
    file_content = file.download_to_string
    attach_file_to(model || question, file_content, fichier_path, question.nom_technique)
  else
    @logger.error "Pas de fichier trouvé sur Google Drive pour '#{fichier_path}'"
  end
rescue GoogleDriveStorage::Error => e
  @logger.error e.message
end

def attach_audio_choix(question)
  question.choix.each do |choix|
    recupere_fichier(question, "#{choix.nom_technique}.mp3", choix)
  end
end

def attach_images_reponses(question)
  question.reponses.each do |choix|
    recupere_fichier(question, "#{choix.nom_technique}.png", choix)
  end
end

def attach_file_to(instance, file_content, fichier_path, nom_technique)
  instance.send(attachment_type(fichier_path)).attach(
    io: StringIO.new(file_content),
    filename: fichier_path,
    content_type: content_type_for(fichier_path)
  )
  @logger.info "#{attachment_type(fichier_path)} est rattaché à la question ##{nom_technique}"
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
