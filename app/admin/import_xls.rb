# frozen_string_literal: true

ActiveAdmin.register_page 'import_xls' do
  menu false

  content title: proc { I18n.t('active_admin.import_question') } do
    render partial: 'admin/questions/import_xls',
           locals: { type: params[:type] }
  end
end
