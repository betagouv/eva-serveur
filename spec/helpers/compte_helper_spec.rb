# frozen_string_literal: true

require "rails_helper"

describe CompteHelper do
  describe "#traduis_acces" do
    it "affiche le statut et le role pour les comptes acceptés" do
      expect(traduis_acces("acceptee", "conseiller")).to eq("Autorisé - Conseiller")
      expect(traduis_acces("acceptee", "admin")).to eq("Autorisé - Admin")
    end

    it "affiche seulement le statut pour les autres statuts" do
      expect(traduis_acces("refusee", "whatever")).to eq("Refusé")
      expect(traduis_acces("en_attente", nil)).to eq("En attente")
    end
  end
end
