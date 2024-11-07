# L'admin peut importer une liste de questions

> [EVA-220](https://captive-team.atlassian.net/browse/EVA-220)

Dans le ticket 209, le travail a été fait pour importer une question avec son contenu.
On va donc se servir de la classe ImportExportQuestion:

On pourrait partir sur qqch comme ça:

```ruby
  def importe_donnees(file)
    sheet = Spreadsheet.open(file.path).worksheet(0)
    sheet.each(1) do |row|
      type = determine_type_question(row)
      question = Question.new(type: type)
      
      # Permettra de récuperer les erreurs en une seule fois plutot que de péter direct à la première erreur
      begin
        ImportQuestion.new(question, HEADERS_ATTENDUS[type]).import_from_xls(file, row)
      rescue ActiveRecord::RecordInvalid => e
        errors << message_erreur_validation(e, row)
      end
    end

    raise ImportQuestion::Error, errors.join("\n") if errors.any?
  end
```

Du coup modifier la  methode pour les messages d'erreurs, afin de rajouter le numéro de ligne:

```ruby
  def message_erreur_validation(exception, row)
    "Erreur ligne #{row}: #{exception.record.errors.full_messages.to_sentence}"
  end
```

Enfin, gérer la redirection après l'import. Aujourd'hui on redirect vers l'edit de la question importée, ce qui ne sera pas possible pour l'ensemble des questions.
Je propose de modifier cette méthode:
```ruby
  def redirection_apres_import(question)
    redirection_paths = {
      'QuestionClicDansImage' => edit_admin_question_clic_dans_image_path(question),
      'QuestionGlisserDeposer' => edit_admin_question_glisser_deposer_path(question),
      'QuestionQcm' => edit_admin_question_qcm_path(question),
      'QuestionSaisie' => edit_admin_question_saisie_path(question),
      'QuestionSousConsigne' => edit_admin_question_sous_consigne_path(question)
    }

    redirection_paths[params[:type]]
  end
```

en un `when`

```ruby
def redirection_apres_import(question)
  case params[:type]
  when 'QuestionClicDansImage'
    admin_question_clic_dans_images_path
  when 'QuestionGlisserDeposer'
    admin_question_glisser_deposers_path
  when 'QuestionQcm'
    admin_question_qcms_path
  when 'QuestionSaisie'
    admin_question_saisies_path
  when 'QuestionSousConsigne'
    admin_question_sous_consignes_path
  else
    admin_questions_path
  end
end
```