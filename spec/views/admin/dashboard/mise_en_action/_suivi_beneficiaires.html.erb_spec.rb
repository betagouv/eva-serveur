require "rails_helper"

describe "admin/dashboard/mise_en_action/_suivi_beneficiaires" do
  it "affiche « Voir tout » comme un lien" do
    render partial: "admin/dashboard/mise_en_action/suivi_beneficiaires",
           locals: { evaluation: nil }

    libelle = I18n.t("admin.dashboard.mise_en_action.suivi_beneficiaires.voir_tout")
    expect(rendered).to have_link(libelle,
                                  href: admin_evaluations_eva_path(scope: :illettrisme_potentiel),
                                  class: "fr-link")
  end
end
