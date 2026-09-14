require "rails_helper"

describe "Rack::Attack" do
  describe "THROTTLE_PAR_SESSION_PATHS" do
    subject(:regex) { Rack::Attack::THROTTLE_PAR_SESSION_PATHS }

    describe "chemins throttlés par session_id (match)" do
      it "matche la création d'un événement unitaire" do
        expect(regex).to match("/api/evenements")
      end

      it "matche l'envoi d'une collection d'événements, quel que soit l'id d'évaluation" do
        expect(regex).to match(
          "/api/evaluations/3fa85f64-5717-4562-b3fc-2c963f66afa6/collections_evenements"
        )
      end
    end

    describe "chemins exclus, toujours throttlés par IP (no match)" do
      it "exclut la ressource evaluations elle-même (show/create/update)" do
        expect(regex).not_to match("/api/evaluations/3fa85f64-5717-4562-b3fc-2c963f66afa6")
      end

      it "exclut la sous-ressource fin d'une évaluation" do
        expect(regex).not_to match("/api/evaluations/3fa85f64-5717-4562-b3fc-2c963f66afa6/fin")
      end

      it "exclut un id d'évaluation contenant un slash (chemin ambigu)" do
        expect(regex).not_to match("/api/evaluations/a/b/collections_evenements")
      end

      it "exclut un sous-chemin de evenements (ex: id en suffixe)" do
        expect(regex).not_to match("/api/evenements/123")
      end

      it "exclut les autres endpoints de l'API" do
        expect(regex).not_to match("/api/campagnes/ABC123")
        expect(regex).not_to match("/api/questionnaires/1")
        expect(regex).not_to match("/api/beneficiaires/XYZ")
      end

      it "exclut les chemins hors API (admin, assets)" do
        expect(regex).not_to match("/admin/beneficiaires")
        expect(regex).not_to match("/assets/application.css")
      end
    end
  end

  describe ".session_id_depuis_le_corps" do
    def requete(body, path: "/api/evenements")
      env = Rack::MockRequest.env_for(
        path, method: "POST", input: body, "CONTENT_TYPE" => "application/json"
      )
      Rack::Attack::Request.new(env)
    end

    it "trouve le session_id à la racine du corps (endpoint evenements)" do
      req = requete({ session_id: "abc-123", nom: "apparitionMot" }.to_json)

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to eq("abc-123")
    end

    it "trouve le session_id imbriqué dans le premier événement (collections_evenements)" do
      req = requete(
        { evaluation_id: "eval-1", evenements: [ { session_id: "def-456", nom: "test" } ] }.to_json
      )

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to eq("def-456")
    end

    it "préfère le session_id racine s'il est présent en plus d'evenements" do
      req = requete(
        {
          session_id: "racine",
          evenements: [ { session_id: "imbrique" } ]
        }.to_json
      )

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to eq("racine")
    end

    it "renvoie nil pour un corps vide" do
      req = requete("")

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to be_nil
    end

    it "renvoie nil pour un JSON invalide, sans lever d'exception" do
      req = requete("{invalide")

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to be_nil
    end

    it "renvoie nil quand ni session_id ni evenements ne sont présents" do
      req = requete({ nom: "test" }.to_json)

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to be_nil
    end

    it "renvoie nil quand evenements est un tableau vide" do
      req = requete({ evenements: [] }.to_json)

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to be_nil
    end

    it "renvoie nil sans lever d'exception quand le JSON racine n'est pas un objet" do
      expect(Rack::Attack.session_id_depuis_le_corps(requete("[1,2,3]"))).to be_nil
      expect(Rack::Attack.session_id_depuis_le_corps(requete('"une chaine"'))).to be_nil
      expect(Rack::Attack.session_id_depuis_le_corps(requete("null"))).to be_nil
    end

    it "renvoie nil sans lever d'exception quand evenements n'est pas un tableau" do
      req = requete({ evenements: "pas un tableau" }.to_json)

      expect(Rack::Attack.session_id_depuis_le_corps(req)).to be_nil
    end

    it "laisse le corps de la requête intact pour une lecture ultérieure (rembobinage)" do
      corps = { session_id: "abc-123" }.to_json
      req = requete(corps)

      Rack::Attack.session_id_depuis_le_corps(req)

      expect(req.body.read).to eq(corps)
    end
  end
end
