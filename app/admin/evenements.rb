# frozen_string_literal: true

ActiveAdmin.register Evenement do
  actions :index, :show, :destroy
  permit_params :donnees, :session_id, :situation, :nom, :date

  filter :situation
  filter :session_id
  filter :date

  index do
    render 'index', context: self
  end
end
