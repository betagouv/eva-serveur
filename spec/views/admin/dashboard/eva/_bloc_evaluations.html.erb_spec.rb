require "rails_helper"

describe "admin/dashboard/eva/_bloc_evaluations" do
  it "affiche « Voir toutes les évaluations » comme un lien" do
    render partial: "admin/dashboard/eva/bloc_evaluations", locals: { evaluations: [] }

    expect(rendered).to have_link(I18n.t("admin.dashboard.eva.bloc_evaluations.voir_tout"),
                                  href: admin_evaluations_eva_path, class: "fr-link")
  end
end
