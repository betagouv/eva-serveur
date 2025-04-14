# frozen_string_literal: true

ActiveAdmin.register_page "Aide" do
  menu priority: 99

  content do
    render "aide",
           categories: SourceAide.categories.keys,
           sources_par_categorie: SourceAide.sources_par_categorie,
           questions_frequentes: Aide::QuestionFrequente.all
  end

  sidebar :menu, class: "menu-sidebar" do
    render partial: "menu_sidebar", locals: { categories: SourceAide.categories.keys }
  end
end
