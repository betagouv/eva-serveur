# frozen_string_literal: true

ActiveAdmin.register SituationConfiguration do
  config.sort_order = 'position_asc'
  reorderable
  permit_params :situation_id

  belongs_to :campagne

  index as: :reorderable_table do
    column :id
    column :position
    column :campagne
    column :situation
    actions
  end
end
