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
SourceAide.find_or_create_by(titre: "Fiche de présentation d'eva") do |source_aide|
  source_aide.description= "Fichier PDF imprimable\n1 page"
  source_aide.url= 'https://drive.google.com/file/d/1dzL55etvlvoaoW7NtSOaK-_Nhdf945C7/view'
  source_aide.categorie= :presenter_eva
  source_aide.type_document= :pdf
end
SourceAide.find_or_create_by(titre: 'Vidéo de démonstration') do |source_aide|
  source_aide.description="Vidéo accessible sur Youtube\nDurée : 3mn46"
  source_aide.url= 'https://youtu.be/wz8SftVc53k'
  source_aide.categorie= :presenter_eva
  source_aide.type_document= :video
end

Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux aider les candidats pendant la passation ?') do |faq|
  faq.reponse= %{La restitution obtenue au terme d’une passation sur l’outil eva peut être considérée valide uniquement si les condition suivantes sont respectées :

la passation a été réalisée d’une traite, c’est à dire que toutes les mises en situation ont été passées à la suite les unes des autres en une seule fois, chaque mise en situation n’a été passée qu’une seule fois, chaque mise en situation a été réalisée dans son entièreté.

Les réponses partielles peuvent être considérées comme des pistes de réflexion ouvrant au dialogue, mais en aucun cas comme une indication précise de niveau de compétence.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux modifier l’ordre des mises en situation dans le parcours ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Quel est le public auquel est destiné eva ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'À quel moment faire passer eva dans le parcours d’accompagnement ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-il possible de refaire le test plusieurs fois ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Comment faciliter la réalisation d’un exercice ? Niveau aide') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux passer à l’exercice suivant sans l’avoir terminé ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux réaliser des passations à distance ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que eva peut être passé sur des tablettes ou des téléphones portables ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Puis-je partager les restitutions complètes avec les candidats ?') do |faq|
  faq.reponse= %{Réponse en cours d'écriture.}
end
