# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  filter :campagne, collection: proc { evaluations_visibles(current_compte) }
  filter :created_at

  index do
    column :nom
    column :campagne
    column :created_at
    column '' do |evaluation|
      span link_to t('.restitution'),
                   admin_restitutions_path(evaluation_id: evaluation.id)
    end
  end
end
