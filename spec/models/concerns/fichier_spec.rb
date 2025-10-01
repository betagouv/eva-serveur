require "rails_helper"

describe Fichier do
  let(:test_class) do
    Class.new do
      include Fichier
    end
  end

  describe "#nom_fichier_horodate" do
    it "genere un nom de fichier horodaté" do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        expect(test_class.new.nom_fichier_horodate("titre", "extention"))
          .to eq("20250228010203-titre.extention")
      end
    end
  end

  describe "#nom_fichier" do
    it "genere un nom de fichier avec la date et l'heure par défaut" do
      expect(test_class.new.nom_fichier(
        Time.zone.local(2025, 2, 28, 12, 05, 06), "titre", "extention"))
        .to eq("20250228-1205-titre.extention")
    end
  end
end
