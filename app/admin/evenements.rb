# frozen_string_literal: true

ActiveAdmin.register Evenement do
  menu if: proc { can? :manage, Compte }
  config.sort_order = 'created_at_desc'

  filter :session_id
  filter :date

  index do
    render 'index', context: self
  end
end
