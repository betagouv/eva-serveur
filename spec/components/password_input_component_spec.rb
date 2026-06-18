require "rails_helper"

describe PasswordInputComponent, type: :component do
  before do
    render_inline(described_class.new(
      id: "compte_password",
      label: "Mot de passe",
      hint: "Doit comporter au moins 8 caractères.",
      required: true
    ))
  end

  it "utilise le wrapper fr-password" do
    expect(page).to have_css("div.fr-password")
  end

  it "ajoute fr-password__label sur le label" do
    expect(page).to have_css("label.fr-password__label.fr-label")
  end

  it "enveloppe l'input dans fr-input-wrap" do
    expect(page).to have_css("div.fr-input-wrap input.fr-password__input.fr-input")
  end

  it "ajoute autocapitalize et autocorrect off sur l'input" do
    expect(page).to have_css("input[type='password'][autocapitalize='off'][autocorrect='off']")
  end

  it "affiche la checkbox pour afficher le mot de passe" do
    expect(page).to have_css("div.fr-password__checkbox")
    expect(page).to have_css("input[type='checkbox']")
    expect(page).to have_css("label", text: "Afficher")
  end

  it "lie la checkbox au bon id" do
    checkbox_id = page.find("input[type='checkbox']")["id"]
    expect(page).to have_css("label[for='#{checkbox_id}']")
  end
end
