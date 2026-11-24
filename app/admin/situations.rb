ActiveAdmin.register Situation do
  liste_dsfr

  permit_params :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id,
                :description, :illustration

  filter :libelle
  filter :nom_technique
  filter :description

  includes :questionnaire, :questionnaire_entrainement, illustration_attachment: :blob

  form do |f|
    f.semantic_errors
    inputs do
      f.input :libelle
      f.input :nom_technique
      f.input :illustration, as: :file
      f.input :description, as: :text
      f.input :questionnaire
      f.input :questionnaire_entrainement
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  show do
    render "show"
  end
end
