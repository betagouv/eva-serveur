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
SourceAide.find_or_create_by(titre: 'Foire Aux Questions') do |source_aide|
  source_aide.description= "Retrouver les réponses aux questions les plus fréquentes sur notre site public."
  source_aide.url= 'https://eva.anlci.gouv.fr/centre-daide'
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

situations_data = [
  { libelle: 'Plan de la ville', nom_technique: 'plan_de_la_ville' },
  { libelle: 'Bienvenue', nom_technique: 'bienvenue' },
  { libelle: 'Café de la place', nom_technique: 'cafe_de_la_place' },
  { libelle: 'Maintenance', nom_technique: 'maintenance' },
  { libelle: 'Livraison', nom_technique: 'livraison' },
  { libelle: 'Tri', nom_technique: 'tri' },
  { libelle: 'Contrôle', nom_technique: 'controle' },
  { libelle: 'Sécurité', nom_technique: 'securite' },
  { libelle: 'Objets trouvés', nom_technique: 'objets_trouves' },
  { libelle: 'Inventaire', nom_technique: 'inventaire' },
  { libelle: 'Place du marché', nom_technique: 'place_du_marche' }
]
situations_data.each do |situation_data|
  Situation.find_or_create_by(nom_technique: situation_data[:nom_technique]) do |situation|
    situation.libelle = situation_data[:libelle]
  end
end

ParcoursType.find_or_create_by(nom_technique: 'complet') do |parcours_type|
  parcours_type.libelle = 'Parcours complet'
  parcours_type.duree_moyenne = '55 minutes'
  parcours_type.type_de_programme = 'diagnostic'
  parcours_type.description = %{Ce parcours permet d'évaluer à la fois :

- **les compétences de base** *(littératie et numératie)*
- **les compétences transversales** *(vitesse d’exécution, attention et concentration, vigilance et contrôle, comparaison et tri, organisation et méthode, compréhension de la consigne, détection et qualification des dangers).*}
  situations = Situation.where(nom_technique: [
    'maintenance',
    'livraison',
    'tri',
    'controle',
    'securite',
    'objets_trouves',
    'inventaire'
  ])
  parcours_type.situations_configurations_attributes = situations.map.with_index do |situation, index|
    { situation_id: situation.id, position: index }
  end
end

ParcoursType.find_or_create_by(nom_technique: 'competences_de_base') do |parcours_type|
  parcours_type.libelle = 'Parcours compétences de base'
  parcours_type.duree_moyenne = '25 minutes'
  parcours_type.type_de_programme = 'diagnostic'
  parcours_type.description = %{Ce parcours permet d'évaluer uniquement **les compétences de base** *(littératie et numératie)*.}
  situations = Situation.where(nom_technique: [
    'maintenance',
    'livraison',
    'objets_trouves'
  ])
  parcours_type.situations_configurations_attributes = situations.map.with_index do |situation, index|
    { situation_id: situation.id, position: index }
  end
end

structure_eva = Structure.where('lower(nom) = ?', 'eva').first_or_create do |structure|
  structure.nom = 'eva'
  structure.code_postal = 75012
  structure.type_structure = 'autre'
  structure.type = 'StructureLocale'
end

Compte.where(email: Eva::EMAIL_SUPPORT).first_or_create do |compte|
  compte.prenom = 'eva'
  compte.nom = 'Bot'
  compte.role = 'superadmin'
  compte.statut_validation = 'acceptee'
  compte.structure = structure_eva
  compte.password = SecureRandom.uuid
end

genre = QuestionQcm.find_or_create_by(nom_technique: 'genre') do |question|
  question.libelle = 'Genre'
  question.categorie = 'situation'
  Transcription.find_or_create_by(question_id: question.id, ecrit: 'Vous êtes ?')
  question.choix = [
    Choix.new(nom_technique: 'homme', intitule: 'Un homme', type_choix: 'bon'),
    Choix.new(nom_technique: 'femme', intitule: 'Une femme', type_choix: 'bon'),
    Choix.new(nom_technique: 'autre', intitule: 'Autre', type_choix: 'bon')
  ]
end

langue_maternelle = QuestionQcm.find_or_create_by(nom_technique: 'langue_maternelle') do |question|
  question.libelle = 'Langue maternelle'
  question.categorie = 'situation'
  Transcription.find_or_create_by(question_id: question.id, ecrit: 'Le français est-il votre langue maternelle ?')
  question.choix = [
    Choix.new(nom_technique: 'oui', intitule: 'Oui', type_choix: 'bon'),
    Choix.new(nom_technique: 'non', intitule: 'Non', type_choix: 'bon'),
  ]
end

lieu_scolarite = QuestionQcm.find_or_create_by(nom_technique: 'lieu_scolarite') do |question|
  question.libelle = 'Lieu de scolarite'
  question.categorie = 'scolarite'
  Transcription.find_or_create_by(question_id: question.id, ecrit: "Êtes-vous allé à l'école ?")
  question.choix = [
    Choix.new(nom_technique: 'france', intitule: 'Oui, en France', type_choix: 'bon'),
    Choix.new(nom_technique: 'etranger', intitule: 'Oui, dans un autre pays', type_choix: 'bon'),
    Choix.new(nom_technique: 'non_scolarise', intitule: 'Non', type_choix: 'bon'),
  ]
end

niveau_etude = QuestionQcm.find_or_create_by(nom_technique: 'dernier_niveau_etude') do |question|
  question.libelle = "Niveau d'étude"
  question.categorie = 'scolarite'
  Transcription.find_or_create_by(question_id: question.id, ecrit: "Quel niveau d'études avez-vous atteint ?")
  question.choix = [
    Choix.new(nom_technique: 'pas_etudie', intitule: "Je ne suis pas allé à l'école", type_choix: 'bon'),
    Choix.new(nom_technique: 'college', intitule: 'Niveau Collège', type_choix: 'bon'),
    Choix.new(nom_technique: 'cfg_dnb', intitule: 'Niveau certificat de formation générale ou diplôme national du brevet', type_choix: 'bon'),
    Choix.new(nom_technique: 'cap_bep', intitule: 'Niveau CAP/BEP', type_choix: 'bon'),
    Choix.new(nom_technique: 'bac', intitule: 'Niveau Bac', type_choix: 'bon'),
    Choix.new(nom_technique: 'bac_plus2', intitule: 'Niveau Bac+2', type_choix: 'bon'),
    Choix.new(nom_technique: 'superieur_bac_plus2', intitule: 'Niveau supérieur à Bac+2', type_choix: 'bon'),
  ]
end

derniere_situation = QuestionQcm.find_or_create_by(nom_technique: 'derniere_situation') do |question|
  question.libelle = 'Dernière situation'
  question.categorie = 'situation'
  Transcription.find_or_create_by(question_id: question.id, ecrit: 'Quelle était votre dernière situation ?')
  question.choix = [
    Choix.new(nom_technique: 'scolarisation', intitule: 'Scolarisation', type_choix: 'bon'),
    Choix.new(nom_technique: 'formation_professionnelle', intitule: 'Formation professionnelle', type_choix: 'bon'),
    Choix.new(nom_technique: 'alternance', intitule: 'Alternance', type_choix: 'bon'),
    Choix.new(nom_technique: 'en_emploi', intitule: 'En emploi', type_choix: 'bon'),
    Choix.new(nom_technique: 'sans_emploi', intitule: 'Sans emploi', type_choix: 'bon'),
  ]
end

age = QuestionSaisie.find_or_create_by(nom_technique: 'age') do |question|
  question.libelle = 'quel age ?'
  question.categorie = 'situation'
  Transcription.find_or_create_by(question_id: question.id, ecrit: "Tout d'abord, merci de renseigner votre âge.")
  question.suffix_reponse = "ans"
  question.type_saisie = 'numerique'
end

difficultes_informatique = QuestionQcm.find_or_create_by(nom_technique: 'difficultes_informatique') do |question|
  question.libelle = "Difficultés avec l'informatique"
  question.categorie = 'appareils'
  Transcription.find_or_create_by(question_id: question.id, ecrit: "Avez-vous des difficultés avec l'outil informatique (maux de tête, difficultés d'utilisation) ?")
  question.choix = [
    Choix.new(nom_technique: 'oui', intitule: 'Oui', type_choix: 'bon'),
    Choix.new(nom_technique: 'non', intitule: 'Non', type_choix: 'bon')
  ]
end
