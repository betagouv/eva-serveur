# frozen_string_literal: true

ActiveAdmin.register_page 'Aide' do
  menu priority: 99

  content do
    sources_aide = SourceAide.all
    render 'aide', sources_aide: sources_aide, titre: 'prise_en_main'
  end
end
