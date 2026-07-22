# frozen_string_literal: true

require "rails_helper"

RSpec.describe BanniereSolutionsIllettrismeComponent, type: :component do
  describe "#code_commune" do
    it "utilise le code commune de la structure du compte de la campagne de l'évaluation" do
      structure_campagne = instance_double(Structure, code_commune: "75056")
      compte_campagne = instance_double(Compte, structure: structure_campagne)
      campagne = instance_double(Campagne, compte: compte_campagne)
      evaluation = instance_double(Evaluation, campagne: campagne)
      autre_structure = instance_double(Structure, code_commune: "13055")
      current_compte = instance_double(Compte, structure: autre_structure)

      component = described_class.new(current_compte: current_compte, evaluation: evaluation)

      expect(component.code_commune).to eq("75056")
    end

    it "retombe sur la structure du compte connecté quand aucune évaluation n'est fournie" do
      structure = instance_double(Structure, code_commune: "13055")
      current_compte = instance_double(Compte, structure: structure)

      component = described_class.new(current_compte: current_compte)

      expect(component.code_commune).to eq("13055")
    end

    it "retourne nil quand le compte de la campagne n'a pas de structure" do
      compte_campagne = instance_double(Compte, structure: nil)
      campagne = instance_double(Campagne, compte: compte_campagne)
      evaluation = instance_double(Evaluation, campagne: campagne)
      current_compte = instance_double(Compte, structure: nil)

      component = described_class.new(current_compte: current_compte, evaluation: evaluation)

      expect(component.code_commune).to be_nil
    end

    it "retourne nil quand ni l'évaluation ni le compte connecté n'ont de structure" do
      current_compte = instance_double(Compte, structure: nil)

      component = described_class.new(current_compte: current_compte)

      expect(component.code_commune).to be_nil
    end
  end

  describe "rendu" do
    it "construit le lien vers la solution de remédiation avec le code commune de la campagne" do
      structure = create(:structure_locale, code_commune: "75056")
      compte_campagne = create(:compte_admin, structure: structure)
      campagne = create(:campagne, compte: compte_campagne)
      evaluation = create(:evaluation, campagne: campagne)
      current_compte = create(:compte_admin)

      render_inline(described_class.new(current_compte: current_compte, evaluation: evaluation))

      expect(page).to have_link(href: /code_commune=75056/)
    end

    it "affiche l'astérisque quand asterisque est vrai" do
      current_compte = create(:compte_admin)

      render_inline(described_class.new(current_compte: current_compte, asterisque: true))

      expect(page).to have_css("#asterisque")
    end
  end
end
