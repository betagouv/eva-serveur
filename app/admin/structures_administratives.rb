ActiveAdmin.register StructureAdministrative do
  config.sort_order = "created_at_desc"

  permit_params :nom, :parent_id, :siret

  # Les filtres sont rendus par FiltresComponent dans l'en-tête de la page ; ransack
  # les applique toujours à partir de params[:q]
  config.filters = false
  config.current_filters = false

  show do
    render partial: "admin/structures/show", locals: { structure: resource }
  end

  form partial: "form"

  controller do
    before_action :entete_index, only: :index

    def entete_index
      @page_title = active_admin_config.plural_resource_label
      @page_dsfr = true
      @filtres = Structures::FiltresListe.new(params[:q], current_compte, activation: nil)
    end
    private :entete_index

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
