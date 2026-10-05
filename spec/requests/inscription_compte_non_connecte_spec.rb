require "rails_helper"

RSpec.describe "Inscription - Compte non connecté", type: :request do
  {
    "informations du compte" => :inscription_informations_compte_path,
    "recherche de structure" => :inscription_recherche_structure_path,
    "structure" => :inscription_structure_path
  }.each do |etape, chemin|
    it "redirige vers la connexion à l'étape #{etape}" do
      get public_send(chemin)

      expect(response).to redirect_to(new_compte_session_path)
    end
  end
end
