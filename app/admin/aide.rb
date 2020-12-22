# frozen_string_literal: true

ActiveAdmin.register_page 'Aide' do
  menu priority: 99

  content do
    render 'aide',
           sources_par_categorie: SourceAide.sources_par_categorie,
           questions_frequentes: Aide::QuestionFrequente.all
  end
end
