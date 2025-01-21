# EVA-288 : Les illustrations des questions sont automatiquement redimensionnées quand elles sont uploadées

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-288)

## Étapes
- Installer la gem image_processing
- Installer Vips sur le projet
- Dans le model QuestionGlisserDeposer:
on va rajouter le resize de la zone depot:
`has_one_attached :zone_depot, resize_to_limit: [1008, 566], preprocessed: true`
- Dans le model Question;
`has_one_attached :illustration, resize_to_limit: [1008, 566], preprocessed: true`