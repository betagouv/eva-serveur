# L'admin peut exporter une liste de questions

> [EVA-219](https://captive-team.atlassian.net/browse/EVA-219)

Après discussion avec le produit, on va vouloir récupérer les questions à partir d'un questionnaires directement.

-----

1. Récupérer les questions par type dans un questionnaire:
`questions.group_by(&:type)`

ça donnerait qqch comme:
```bash
  {
    "QuestionSousConsigne"=>
      [
        #<QuestionSousConsigne:0x0000000109a9cc70
        created_at: Mon, 30 Sep 2024 17:02:41.165728000 CEST +02:00,
        updated_at: Mon, 30 Sep 2024 17:02:41.165728000 CEST +02:00,
        type: "QuestionSousConsigne",
        description: nil,
        reponse_placeholder: nil,
        suffix_reponse: nil,
        libelle: "Sous consigne - Autopositionnement",
        id: "33982b4d-d9ca-48fb-9da7-fadc062f8c8c",
        metacompetence: nil,
        type_qcm: 0,
        nom_technique: "sous_consigne_autopositionnement",
        deleted_at: nil,
        type_saisie: 0,
        categorie: nil>
      ],
    "QuestionQcm"=>
      [
        #<QuestionQcm:0x000000010ae1eed8
        created_at: Tue, 12 Nov 2024 17:09:43.630880000 CET +01:00,
        updated_at: Tue, 12 Nov 2024 17:09:43.630880000 CET +01:00,
        type: "QuestionQcm",
        description: nil,
        reponse_placeholder: nil,
        suffix_reponse: nil,
        libelle: "LOdi1",
        id: "0febe7ec-471e-4c5f-ac6f-a616fcba1804",
        metacompetence: nil,
        type_qcm: "standard",
        nom_technique: "lodi_1",
        deleted_at: nil,
        type_saisie: 0,
        categorie: nil>
    ],
  }
```


2. À partir de là on va pouvoir appeler le service d'export afin d'exporter par type.

  Dans la class `ImportExportDonnees`:
  ```ruby
    def initialize(question: nil, type: nil)
      @question = question
      @type = type
    end
  ```
Je veux changer question en questions, afin de lui passer une collection de Question en plus du type

3. On va modifier le model d'export afin d'exporter un ou plusieurs questions à la fois
   Je vais modifier la méthode remplie la feuille pour lui donner ma collection de questions
```ruby
    def remplie_la_feuille
      @questions.each_with_index do |question, index|
        @question = question
        remplis_champs_commun(index + 1)
      end
    end
```

mais avant tout ça des tests, meme si tester c'est douter

Bonus: Ajouter des icones pour les boutons d'import et export