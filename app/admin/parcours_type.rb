ActiveAdmin.register ParcoursType do
  liste_dsfr { |parametres| Referentiels::FiltresListe.new(parametres) }

  permit_params :libelle, :actif, :position, :nom_technique,
                :duree_moyenne, :description, :type_de_programme,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  form partial: "form"

  show do
    render partial: "show"
  end
end
