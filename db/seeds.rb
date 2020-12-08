# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

SourceAide.find_or_create_by(titre: 'Vidéo explicative pour les conseiller·ère·s') do |source_aide|
  source_aide.description="Vidéo accessible sur Youtube\nDurée : 5mn27"
  source_aide.url='https://youtu.be/WC9nICmMgbY'
  source_aide.categorie=:prise_en_main
  source_aide.type_document=:video
end
SourceAide.find_or_create_by(titre: 'Guide de prise en main') do |source_aide|
  source_aide.description= "Fichier PDF imprimable\n14 pages"
  source_aide.url= 'https://drive.google.com/file/d/1VzZLNJ8pw5MihpSqZj1qEVAwXvRlkiOE/view'
  source_aide.categorie= :prise_en_main
  source_aide.type_document= :pdf
end
SourceAide.find_or_create_by(titre: 'Exemples de restitution') do |source_aide|
  source_aide.description= "Plusieurs exemples de restitution eva selon les niveaux alerte illettrisme\n\nFichiers PDF de 4 pages"
  source_aide.url= 'https://drive.google.com/drive/u/1/folders/1tOCcjxxT9P_UL6r4CXVScEiN090j3IA2'
  source_aide.categorie= :prise_en_main
  source_aide.type_document= :repertoire
end
SourceAide.find_or_create_by(titre: 'Vidéo introductive pour les candidats et les candidates') do |source_aide|
  source_aide.description="Vidéo accessible sur Youtube\nDurée : 1mn50"
  source_aide.url= 'https://youtu.be/T7Gh0sMZBqY'
  source_aide.categorie= :animer_restituer
  source_aide.type_document= :video
end
SourceAide.find_or_create_by(titre: 'Document d’interprétation des résultats eva en français et mathématiques') do |source_aide|
  source_aide.description= "Document consultable en ligne"
  source_aide.url= 'https://docs.google.com/document/d/e/2PACX-1vQ0mYR22VK-y_vX0buYtxTQBb6VuLZbMKfDuU0O7p1pi_y5nsbP1HOhiW5MPysbAhszxNIQ4lIin8s6/pub'
  source_aide.categorie= :animer_restituer
  source_aide.type_document= :web_doc
end
