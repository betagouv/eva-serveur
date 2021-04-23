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
  faq.reponse= %{Les passations d’eva doivent être accompagnées. Cela signifie qu’un·e encadrant·e doit être présent·e pour aider les candidat·es lorsqu’ils rencontrent des difficultés majeures dans le parcours. Cependant, il est préférable de limiter au maximum les interventions dans les exercices car cela peut influencer les résultats qui seront alors moins représentatifs du niveau réel des candidat·es.

Les exercices les plus difficiles proposent un niveau d’aide (cf. question « existe t-il des niveaux d’aide sur les exercices ? »). Il est également possible de quitter un exercice sans l’avoir terminé si les candidat·es rencontrent encore des difficultés après avoir mobilisé le niveau d’aide (cf. question « peut-on passer un exercice sans l’avoir terminé »).

Dans le cas où vous utiliseriez eva pour un aspect majoritairement pédagogique (c’est à dire sans vous intéresser aux résultats sur les compétences), vous pouvez intervenir auprès des candidat·es les plus en difficultés pour les aider à terminer et gagner confiance en eux, tout en sachant que les résultats ne seront pas représentatifs de leurs compétences.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Existe t-il des niveaux d’aide sur les exercices ?') do |faq|
  faq.reponse= %{Pour les candidat·es en difficulté, certains exercices proposent un niveau d’aide. Par exemple, la situation inventaire et sécurité propose une aide située en bas de l’écran (bouton « j’ai besoin d’aide »). Ces niveaux d’aide ont deux fonctions. Premièrement, ils permettent aux candidat·es d’être évalué·es sur toutes les parties d’un exercice (de sorte qu’un échec dans une première partie n’entraîne pas forcément un échec dans une seconde partie). Deuxièmement, ils permettent de limiter les frustrations liées aux échecs en accompagnant les candidat·es jusqu’à la fin des exercices, dans l’optique de les mettre dans les meilleures dispositions pour les exercices suivants.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Peut-on passer un exercice sans l’avoir terminé ?') do |faq|
  faq.reponse= %{Pour disposer d’un maximum de données sur les candidat·es (et donc pour s’assurer de la fiabilité des résultats), il est préférable de terminer les exercices. Mais dans le cas où les candidat·es sont bloqués et ne peuvent pas poursuivre, ils ou elles peuvent quitter l’exercice et passer au suivant en cliquant sur le bouton « arrêter la situation » en bas à droite de l’écran.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux modifier l’ordre des mises en situation dans le parcours ?') do |faq|
  faq.reponse= %{Il n’est pas préférable de modifier l’ordre des exercices car les tests de fiabilité d’eva ont été réalisés sur la base du parcours type. En modifiant l’ordre des exercices, on risque de perdre en fiabilité dans la mesure des compétences.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'A quel public s’adresse eva ?') do |faq|
  faq.reponse= %{eva s’adresse à toutes les personnes éloignées de l’emploi. Si le public jeune représente la majorité des utilisateurs, eva s’adresse à toutes les personnes en insertion, chômeuses de longue durée, bénéficiaires du RSA…

  eva permet de détecter les personnes potentiellement en situation d’illettrisme. Si la situation d’illettrisme d’une personne est déjà confirmée, alors le parcours eva n’est pas particulièrement indiqué.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'A quel moment dans le parcours d’accompagnement est-il indiqué de faire passer eva ?') do |faq|
  faq.reponse= %{eva est souvent mobilisé en entrée de parcours. C’est un outil polyvalent qui répond à un ensemble de cas d’usage, que ce soit lors d’accompagnement à l’orientation, à l’emploi ou en entrée de formation par exemple.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-il possible de refaire le test plusieurs fois ?') do |faq|
  faq.reponse= %{Les résultats d’eva ne sont fiabilisés que pour une unique passation, lorsque le ou la candidate découvre les mises en situation. Ainsi, pour limiter les biais et donc obtenir un diagnostic le plus juste possible, il est préférable de n’utiliser eva qu’une seule fois. Par exemple, l’habituation aux mises en situation peut participer à l’amélioration des résultats à la deuxième passation.

  Cependant, dans une visée plus pédagogique, notamment pour encourager les candidat·es dans leurs progrès, vous pourriez utiliser eva à nouveau.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Peut-on découper la passation en plusieurs temps ?') do |faq|
  faq.reponse= "Aujourd’hui, eva ne permet pas de découper la passation en plusieurs temps, car les calculs de fiabilité ont été réalisés à partir de données de participants ayant passé le parcours complet d’une seule traite. Ainsi, en réalisant le parcours de façon « découpée », nous pourrions perdre en fiabilité des mesures et donc diminuer la qualité des résultats. Si cela constitue un frein pour vous en tant qu’accompagnant·e, n’hésitez pas à nous écrire à [#{Eva::EMAIL_CONTACT}](mailto:#{Eva::EMAIL_CONTACT}) et nous dire pourquoi."
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce que je peux réaliser des passations à distance ?') do |faq|
  faq.reponse= %{Il est tout à fait possible de réaliser des sessions à distance. Nous avons même créé un petit guide pour vous accompagner dans l’utilisation d’eva à distance : Guide du distanciel}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Est-ce qu’eva peut être passé sur des tablettes ou des téléphones portables ?') do |faq|
  faq.reponse= %{eva est compatible avec tous les types de matériel : ordinateur, tablettes ou téléphone portable. Cependant, certains exercices, comme l’inventaire, nécessitent de faire des manipulations assez précises. Plus l’écran est petit, plus la tâche peut être difficile. Quand cela est possible, il est préférable de privilégier l’usage d’un ordinateur.}
end
Aide::QuestionFrequente.find_or_create_by(question: 'Puis-je partager les restitutions complètes avec les candidats ?') do |faq|
  faq.reponse= %{Il existe deux types de restitution. La restitution pour les candidat·es est délivrée en fin de parcours (bâtiment « résultats »), et présente les deux compétences transversales les plus fortes, afin de valoriser les potentialités des candidat·es.

  Les accompagnant·es disposent quant à eux, en se connectant à l’interface d’administration, d’une restitution plus complète sur les compétences transversales mais également sur les compétences de base. Cette restitution est disponible en PDF et peut être tout à fait partagée avec les candidat·es, si cela s’y prête.}
end

situations_data = [
  { libelle: 'Bienvenue', nom_technique: 'bienvenue' },
  { libelle: 'Livraison', nom_technique: 'livraison' },
  { libelle: 'Inventaire', nom_technique: 'inventaire' },
  { libelle: 'Objets trouvés', nom_technique: 'objets_trouves' },
  { libelle: 'Contrôle', nom_technique: 'controle' },
  { libelle: 'Sécurité', nom_technique: 'securite' },
  { libelle: 'Tri', nom_technique: 'tri' },
  { libelle: 'Bureau', nom_technique: 'questions' },
  { libelle: 'Prévention', nom_technique: 'prevention' },
  { libelle: 'Maintenance', nom_technique: 'Maintenance' }
]
situations_data.each do |situation_data|
  Situation.find_or_create_by(nom_technique: situation_data[:nom_technique]) do |situation|
    situation.libelle = situation_data[:libelle]
  end
end

ParcoursType.find_or_create_by(nom_technique: 'complet') do |parcours_type|
  parcours_type.libelle = 'Parcours complet'
  parcours_type.duree_moyenne = '1 heure'
  situations = Situation.where(nom_technique: situations_data.pluck(:nom_technique))
  parcours_type.situations_configurations_attributes = situations.map { |situation| { situation_id: situation.id } }
end
