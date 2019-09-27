# frozen_string_literal: true

ActiveAdmin.register Evenement do
  menu if: proc { can? :manage, Compte }
  permit_params :donnees, :session_id, :situation, :nom, :date
  config.sort_order = 'created_at_desc'

  filter :situation
  filter :session_id
  filter :date

  index do
    render 'index', context: self
  end
end
