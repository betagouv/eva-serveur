# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Evenement, as: 'Evaluations' do
  config.sort_order = 'date_desc'
  actions :index, :show

  controller do
    def scoped_collection
      end_of_association_chain.where(nom: 'demarrage')
    end

    def find_resource
      EvaluationInventaire.new(
        Evenement.where(session_id: params[:id]).order(:date)
      )
    end
  end

  index do
    column :situation
    column :session_id
    column :date
    column '' do |evenement|
      link_to t('.rapport'), admin_evaluation_path(id: evenement.session_id)
    end
  end

  show title: :session_id do
    evaluation = resource
    table do
      thead do
        tr do
          th
          evaluation.essais.each_with_index do |essai, index|
            if essai.abandon? || essai.en_cours?
              th
            else
              th t('.essai', count: index + 1)
            end
          end
        end
      end
      tr do
        th t('.etat')
        evaluation.essais.each do |essai|
          td do
            if essai.reussite?
              status_tag t('.reussite'), class: 'green'
            elsif essai.abandon?
              status_tag t('.abandon'), class: 'red'
            elsif essai.en_cours?
              status_tag t('.en_cours')
            else
              status_tag t('.echec'), class: 'red'
            end
          end
        end
      end
      tr do
        th t('.temps')
        evaluation.essais.each do |essai|
          td "+#{distance_of_time_in_words(essai.temps_total)}"
        end
      end
      tr do
        th t('.ouverture_contenant')
        evaluation.essais.each do |essai|
          td essai.nombre_ouverture_contenant
        end
      end
    end
  end

  sidebar :info, only: :show do
    attributes_table_for resource do
      row(t('.etat')) do |evaluation|
        if evaluation.reussite?
          status_tag t('.reussite'), class: 'green'
        elsif evaluation.abandon?
          status_tag t('.abandon'), class: 'red'
        else
          status_tag t('.en_cours')
        end
      end
      row(t('.temps')) { |evaluation| distance_of_time_in_words(evaluation.temps_total) }
      row :nombre_ouverture_contenant
      row :nombre_essais_validation
    end
  end
end
# rubocop:enable Metrics/BlockLength
