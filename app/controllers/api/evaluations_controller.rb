module Api
  class EvaluationsController < Api::BaseController
    def create
      evaluation = Evaluation.new(evaluation_params)
      initialise_conditions_passation(evaluation.conditions_passation)
      if evaluation.save
        render partial: "evaluation",
               locals: { evaluation: evaluation },
               status: :created
      else
        retourne_erreur(evaluation)
      end
    end

    def show
      @evaluation = Evaluation.find(evaluation_params[:id])

      render partial: "evaluation",
             locals: { evaluation: @evaluation }
    end

    def update
      ActiveRecord::Base.transaction do
        @evaluation = Evaluation.find(evaluation_params[:id])
        if @evaluation.update evaluation_params
          render partial: "evaluation",
                 locals: { evaluation: @evaluation }
        else
          retourne_erreur(@evaluation)
        end
      end
    end

    private

    def initialise_conditions_passation(conditions_passation)
      return unless conditions_passation

      client = DeviceDetector.new(conditions_passation.user_agent)
      conditions_passation.materiel_utilise = client.device_type
      conditions_passation.modele_materiel = client.device_name
      conditions_passation.nom_navigateur = client.name
      conditions_passation.version_navigateur = client.full_version
    end

    def evaluation_params
      return @evaluation_params if @evaluation_params.present?

      @evaluation_params = permit_params
      retrouve_ids_nested_attributes
      traite_beneficiaire
      @evaluation_params
    end

    def permit_params
      permitted_params = [ :id, :code_beneficiaire, :code_campagne, :terminee_le, :debutee_le,
                         :beneficiaire_id, conditions_passation_attributes:
                         %i[user_agent hauteur_fenetre_navigation largeur_fenetre_navigation],
                         donnee_sociodemographique_attributes:
                         %i[age genre dernier_niveau_etude derniere_situation] ]

      params.permit(permitted_params)
    end

    def retrouve_ids_nested_attributes
      nested_modeles = %i[donnee_sociodemographique
                          conditions_passation
                          mises_en_action]
      nested_modeles.each do |nested_model|
        attributs = "#{nested_model}_attributes"
        if @evaluation_params[attributs.to_sym]
          @evaluation_params[attributs.to_sym][:id] =
            nested_model.to_s.camelize.constantize.find_by(evaluation_id: params[:id])&.id
        end
      end
    end

    def retourne_erreur(evaluation)
      evaluation.errors.delete(:'beneficiaire.nom')
      render json: evaluation.errors, status: :unprocessable_entity
    end

    def traite_beneficiaire
      if @evaluation_params[:code_beneficiaire].present?
        traite_avec_code_beneficiaire
      elsif params[:nom].present? && params[:id].blank?
        construit_beneficiaire_attributes(params[:nom])
      end
    end

    def traite_avec_code_beneficiaire
      code = @evaluation_params.delete(:code_beneficiaire)
      beneficiaire = Beneficiaire.find_by(code_beneficiaire: code)

      return unless beneficiaire

      @evaluation_params[:beneficiaire_id] = beneficiaire.id
    end

    def construit_beneficiaire_attributes(nom)
      @evaluation_params[:beneficiaire_attributes] = { nom: nom }
      @evaluation_params.delete(:code_beneficiaire)
    end
  end
end
