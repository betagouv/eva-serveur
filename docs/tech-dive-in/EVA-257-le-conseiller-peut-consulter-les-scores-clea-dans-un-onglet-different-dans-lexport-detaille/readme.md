# EVA-257 : Le conseiller peut consulter les scores Cléa dans un onglet différent dans l'export détaillé

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-257?atlOrigin=eyJpIjoiNTRjYTE4ZTUxMzg0NDgxZmI4NTY5NWNkZTNmMTM0MjQiLCJwIjoiaiJ9)

## 1 - Creer un nouvel onglet synthese dans le fichier avec les entetes

On va devoir faire un peu de refacto afin de pouvoir creer l'onglet `Synthese` avec les bons entetes.

Dans `models/import_export/` on va creer: 

- un fichier `creation_sheet_xls.rb`

- extraire la methode `initialise_sheet` qui se trouve dans `export_xls.rb`

- deplacer cette methode dans le fichier `creation_sheet_xls.rb`. 

Le but est de pouvoir appeler cette methode sur `ImportExport::CreationSheetXls.new(MES PARAMETTRE PAR ONGLET).initialise_sheet` et lui passer les paramettres suivants : le `nom de l'onglet`, les `entetes souhaités` et le `workbook`.


Les entetes sont à définir dans une constante se trouvant dans le fichier `export_donnees.rb`

```ruby
  ENTETES_SYNTHESE = [
    { titre: 'Points', taille: 20 },
    { titre: 'Points maximum', taille: 10 },
    { titre: 'Score', taille: 10 }
  ].freeze
```

## 2 - Ajouter les donnees correspondants aux sous domaines

On va devoir extraire les donnees sous domaines et sous-sous domaine dans la page `synthese` et retirer de `Donnees`

Pour cela on va changer un peu le fonctionnement des methodes `remplis_par_sous_domaine` et `remplis_par_sous_sous_domaine`

⚠️ Il faudra changer l'ordre des colonnes dans l'onglet `Donnees` (Les scores se trouvants a la fin doivent se retrouver en colonne 4 et 5 )

## 3 - Mettre de la couleur.

Les couleurs se trouvent uniquement sur les tableaux des `synthese`. Pour la couleur des entetes, on va devoir refactoriser un peu le code encore une fois et lui passer les paramettre de couleur

`Spreadsheet::Format.new(weight: :bold, pattern_fg_color: :yellow, pattern: 1 )`

Le prb rencontré : La customisation de la couleur ne fonctionne pas.

## A VERIFIER :

⚠️ Faire attention que ca n'impacte pas les autres fichier d'export de questions.