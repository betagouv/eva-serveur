# frozen_string_literal: true

ActiveAdmin.register_page 'Aide' do
  menu priority: 99

  content do
    SourceAide.sources_par_categorie.each do |categorie, sources|
      render 'aide', sources_aide: sources, titre: categorie
    end
  end
end
