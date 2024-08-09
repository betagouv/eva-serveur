<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer une question Saisie de nombre

> [EVA-174](https://captive-team.atlassian.net/browse/EVA-174)

## Prérequis

## Backend

- Modifier le script js du form question pour afficher le choix pour QuestionSaisie également

```javascript
<script>
  function initialize() {
    const inputTypeQcm = document.getElementById("question_qcm_type_input");
    const inputTypeSaisie = document.getElementById("question_saisie_type_input");
    inputTypeQcm || inputTypeSaisie ? $('.choix').show() : $('.choix').hide();
  }

  function displayInputChoixOnCreate() {
    $('#question_type_input').on('change', function(event) {
      event.target.value === 'QuestionQcm' || event.target.value === 'QuestionSaisie' ? $('.choix').show() : $('.choix').hide();
    });
  }

  function displayInputChoixOnEdit() {
    $('#question_saisie_type_input').on('change', function(event) {
      switch (event.target.value) {
        case 'QuestionQcm':
        case 'QuestionSaisie':
          $('.choix').show();
          break;
        default:
          $('.choix').hide();
      }
    });
    $('#question_qcm_type_input').on('change', function(event) {
      switch (event.target.value) {
        case 'QuestionQcm':
        case 'QuestionSaisie':
          $('.choix').show();
          break;
        default:
          $('.choix').hide();
      }
    });
  }

  document.addEventListener('DOMContentLoaded', () => {
    initialize();
    displayInputChoixOnCreate();
    displayInputChoixOnEdit();
  });
</script>
```

- Cacher le bouton `button has_many_add` et le bouton `button has_many_remove` si l'utilisateur choisit l'interaction `QuestionSaisie`
- Apporter une validation sur l'input qui doit être de type numerique

- Rajouter le `:type_saisie` dans le formulaire de création d'une question

```ruby
    f.input :type_saisie, input_html: { value: 1 }, as: :hidden
```
- Rajouter un before_save au modèle Question pour reset le type_saisie si il s'agit d'une question autre

```ruby
  before_save :reinitialise_type_saisie

  def reinitialise_type_saisie
    return unless type.QuestionSaisie?

    self.type_saisie = nil
  end
```
