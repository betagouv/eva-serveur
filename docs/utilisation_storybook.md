Storybook est un outil frontend qui se matérialise comme une librairie pour construire, documenter et tester nos composants UI.

## Initialiser le composant
[En savoir plus](https://viewcomponent.org/)

Créer un nouveau fichier .rb dans le dossier 'app/components' avec les paramètres dont votre composant aura besoin pour fonctionner.

``` ruby
class ExampleComponent < ViewComponent::Base

  def initialize(**params)
    @params = params
  end
end
```

## Créer la vue du composant

Créer dans le même dossier un fichier html.

## Écrire une story

Une “Story” capture le rendu d’un composant UI dans un certain état.

Écrire les différentes stories de ce composant dans un nouveau fichier .rb dans le dossier 'spec/components/stories'.


``` ruby
class ExampleComponentStories < ViewComponent::Storybook::Stories
  story :default do
    constructor(params)
  end
end
```

Puis lancer la tâche rake pour ajouter les nouvelles stories dans le storybook.

    $> bundle exec rake view_component_storybook:write_stories_json

Vérifier qu'elles ont bien été ajoutées en lançant le serveur.

    $> npm run storybook

## Utiliser le composant dans le reste de l'app

```
render(ExampleComponent.new(params))
```
