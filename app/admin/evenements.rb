# frozen_string_literal: true

ActiveAdmin.register Evenement do
  menu if: proc { can? :manage, Compte }
  permit_params :donnees, :session_id, :situation, :nom, :date

  filter :situation
  filter :session_id
  filter :date

  index do
    render 'index', context: self
  end
end
