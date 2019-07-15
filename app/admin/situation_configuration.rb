# frozen_string_literal: true

ActiveAdmin.register SituationConfiguration do
  permit_params :situation_id, :position

  belongs_to :campagne
end
