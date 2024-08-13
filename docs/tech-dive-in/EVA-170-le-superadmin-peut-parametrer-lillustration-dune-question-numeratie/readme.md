<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer l’illustration d’une question numératie

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-170?atlOrigin=eyJpIjoiODVkNzRlZjE3ZmU1NDNlMjkwZTVkN2IzYmYwNzE3ZjkiLCJwIjoiaiJ9)


## 1 - Ajout d'un nouveau champs.

Ajouter dans le model `Question` : `has_one_attached :image`

## 2 - Ajouter une validation sur le type de fichier coté back

On souhaite authoriser uniquement les fichier JPG, PNG et WebP. Donc ajouter dans le model `Question`

```ruby
  validates :image,
            blob: { content_type: ["image/png", "image/jpeg", "image/webp"] }
```

## 3 - Redimensionner l'image

Il va falloir redimensionner les images `1008x566`
Pour ce faire il y a plusieurs etapes :

- Ajouter la gem image_processing
- Dans le .buildpack ajouter `https://github.com/Scalingo/apt-buildpack.git`
- Creer un fichier Aptfile dans lequel on ajoutera `libvips-dev`

Modifier le model :

```ruby
has_one_attached :photo do |attachable|
  attachable.variant :thumb,
                     resize_to_limit: [1008, 566],
                     preprocessed: true
end
```

## 4 - Ajouter le champs dans le formulaire

Dans le formulaire `question_qcms/_form.html.arb` ajouter:

`f.input :image, as: :file, input_html: { accept: 'image/png,image/jpg,image/jpeg' }`

Ne pas oublier de le preciser dans les permit_params

Ajouter egalement un hint sur ce champs :
`La taille de l’image rendu est 1008x566`

## 5 - Ajouter la traduction du champs.

Ceci se passe dans le fichier `question_qcms.yml` en ajoutant la traduction suivante : `Image du jeu`

## 6 - Niveau des droits

Seul le super admin peut ajouter une image. Les droits pour ajouter des questions sont deja destiné uniquement aux superadmin. Donc rien a faire de ce coté.