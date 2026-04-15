require "rails_helper"

RSpec.describe Admin::ComparaisonHelper, type: :helper do
  def ligne_passation(date:, profil:)
    evaluation = instance_double(Evaluation, debutee_le: date)
    { evaluation: evaluation, profil: profil }
  end

  describe "#paragraphes_litteratie" do
    it "retourne un seul paragraphe quand il n'y a qu'une passation" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil2),
        { evaluation: nil }
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.size).to eq(1)
      expect(result.first[:texte]).to include("la personne évaluée")
      expect(result.first[:texte]).to include(
        "rencontre de fortes difficultés pour communiquer en français à l’écrit"
      )
    end

    it "retourne deux paragraphes quand les profils sont différents" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil2),
        ligne_passation(date: Date.new(2026, 2, 10), profil: :profil3)
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.size).to eq(2)
      expect(result.first[:texte]).to include(
        "rencontre de fortes difficultés pour communiquer en français à l’écrit"
      )
      expect(result.second[:texte]).to include(
        "rencontre quelques difficultés pour communiquer en français à l’écrit"
      )
      expect(result.second[:texte]).not_to include("maintient un niveau général identique")
    end

    it "affiche la phrase de maintien sur la 2e passation quand le profil est identique" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil_4h_plus),
        ligne_passation(date: Date.new(2026, 2, 10), profil: :profil_4h_plus)
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.size).to eq(2)
      expect(result.second[:texte]).to include("maintient un niveau général identique")
      expect(result.second[:texte]).to include("Profil 4+")
    end

    it "considère profil4 et profil_4h comme identiques" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil4),
        ligne_passation(date: Date.new(2026, 2, 10), profil: :profil_4h)
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.size).to eq(2)
      expect(result.second[:texte]).to include("maintient un niveau général identique")
      expect(result.second[:texte]).to include("Profil 4")
    end

    it "mappe profil_4h vers le texte de profil4" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil_4h),
        { evaluation: nil }
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.first[:texte]).to include(
        "maîtrise les bases de la communication en français à l’écrit"
      )
      expect(result.first[:texte]).to include("niveau du CFG")
    end

    it "utilise le texte indéterminé si le profil est absent" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: nil),
        { evaluation: nil }
      ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result.size).to eq(1)
      expect(result.first[:texte]).to include("n’a pas de profil déterminé en littératie")
    end

    it "retourne un tableau vide quand il n'y a aucune passation" do
      tableau = [ { evaluation: nil }, { evaluation: nil } ]

      result = helper.paragraphes_litteratie(tableau)

      expect(result).to eq([])
    end
  end

  describe "#paragraphes_numeratie" do
    it "retourne un seul paragraphe quand il n'y a qu'une passation" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil2),
        { evaluation: nil }
      ]

      result = helper.paragraphes_numeratie(tableau)

      expect(result.size).to eq(1)
      expect(result.first[:texte]).to include("la personne évaluée")
      expect(result.first[:texte]).to include(
        "rencontre de fortes difficultés pour calculer et raisonner"
      )
    end

    it "retourne deux paragraphes quand les profils sont différents" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil2),
        ligne_passation(date: Date.new(2026, 2, 10), profil: :profil3)
      ]

      result = helper.paragraphes_numeratie(tableau)

      expect(result.size).to eq(2)
      expect(result.first[:texte]).to include(
        "rencontre de fortes difficultés pour calculer et raisonner"
      )
      expect(result.second[:texte]).to include(
        "rencontre quelques difficultés pour calculer et raisonner"
      )
      expect(result.second[:texte]).not_to include("maintient un niveau général identique")
    end

    it "affiche la phrase de maintien sur la 2e passation quand le profil est identique" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: :profil4_plus),
        ligne_passation(date: Date.new(2026, 2, 10), profil: :profil4_plus)
      ]

      result = helper.paragraphes_numeratie(tableau)

      expect(result.size).to eq(2)
      expect(result.second[:texte]).to include("maintient un niveau général identique")
      expect(result.second[:texte]).to include("Profil 4+")
    end

    it "utilise le texte indéterminé si le profil est absent" do
      tableau = [
        ligne_passation(date: Date.new(2026, 1, 10), profil: nil),
        { evaluation: nil }
      ]

      result = helper.paragraphes_numeratie(tableau)

      expect(result.size).to eq(1)
      expect(result.first[:texte]).to include("n’a pas de profil déterminé en numératie")
      expect(result.first[:texte]).not_to include("maintient un niveau général identique")
    end
  end
end
