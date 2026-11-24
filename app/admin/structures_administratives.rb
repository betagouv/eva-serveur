ActiveAdmin.register StructureAdministrative do
  liste_dsfr

  config.sort_order = "created_at_desc"

  permit_params :nom, :parent_id, :siret

  filter :nom, filters: [ :contains_unaccent, :eq ]
  filter :siret
  filter :created_at

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  form partial: "form"

  controller do
    before_action :trouve_campagnes, only: :show

    def trouve_campagnes
      @campagnes = Campagne.de_la_structure(resource)
    end

    def create
      @structure_administrative = StructureAdministrative.new(
          permitted_params[:structure_administrative]
        )
      @structure_administrative.current_ability = current_ability

      if @structure_administrative.save
        redirect_to admin_structure_administrative_path(@structure_administrative)
      else
        render :new
      end
    end

    def update
      @structure_administrative = resource
      @structure_administrative.current_ability = current_ability

      if @structure_administrative.update(permitted_params[:structure_administrative])
        redirect_to admin_structure_administrative_path(@structure_administrative)
      else
        render :edit
      end
    end
  end
end
