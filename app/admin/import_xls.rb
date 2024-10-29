# frozen_string_literal: true

ActiveAdmin.register_page 'import_xls' do
  menu false

  content title: 'Importer question' do
    render partial: 'admin/questions/import_xls',
           locals: { url: params[:url] }
  end
end
