# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  actions :index, :show

  index do
    selectable_column
    column :nom
    column :created_at
    column '' do |evaluation|
      span link_to t('.restitution'),
                   admin_restitutions_path(evaluation_id: evaluation.id)
    end
  end
end
