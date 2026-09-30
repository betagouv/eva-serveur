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

  describe ".connexion?" do
    def requete(path, method: "POST")
      Rack::Attack::Request.new(Rack::MockRequest.env_for(path, method: method))
    end

    it "reconnaît l'envoi du formulaire de connexion" do
      expect(Rack::Attack.connexion?(requete("/admin/login"))).to be true
    end

    it "reconnaît les variantes de chemin acceptées par le routeur" do
      expect(Rack::Attack.connexion?(requete("/admin/login.json"))).to be true
      expect(Rack::Attack.connexion?(requete("/admin/login/"))).to be true
    end

    it "ignore l'affichage de la page de connexion" do
      expect(Rack::Attack.connexion?(requete("/admin/login", method: "GET"))).to be false
    end

    it "ignore les autres chemins" do
      expect(Rack::Attack.connexion?(requete("/admin/password"))).to be false
      expect(Rack::Attack.connexion?(requete("/admin/login/autre"))).to be false
    end
  end

  describe ".email_de_connexion" do
    def requete(params)
      Rack::Attack::Request.new(
        Rack::MockRequest.env_for("/admin/login", method: "POST", params: params)
      )
    end

    def requete_json(corps)
      env = Rack::MockRequest.env_for(
        "/admin/login.json", method: "POST", input: corps, "CONTENT_TYPE" => "application/json"
      )
      Rack::Attack::Request.new(env)
    end

    it "trouve l'email du formulaire" do
      req = requete(compte: { email: "moi@exemple.fr", password: "secret" })

      expect(Rack::Attack.email_de_connexion(req)).to eq("moi@exemple.fr")
    end

    it "normalise la casse et les espaces, comme Devise" do
      req = requete(compte: { email: "  Moi@Exemple.FR " })

      expect(Rack::Attack.email_de_connexion(req)).to eq("moi@exemple.fr")
    end

    it "trouve l'email dans un corps JSON" do
      req = requete_json({ compte: { email: "Moi@exemple.fr" } }.to_json)

      expect(Rack::Attack.email_de_connexion(req)).to eq("moi@exemple.fr")
    end

    it "renvoie nil quand l'email est absent ou vide" do
      expect(Rack::Attack.email_de_connexion(requete({}))).to be_nil
      expect(Rack::Attack.email_de_connexion(requete(compte: { email: " " }))).to be_nil
    end

    it "renvoie nil sans lever d'exception quand les paramètres sont inattendus" do
      expect(Rack::Attack.email_de_connexion(requete(compte: "pas un hash"))).to be_nil
      expect(Rack::Attack.email_de_connexion(requete_json("{invalide"))).to be_nil
      expect(Rack::Attack.email_de_connexion(requete_json("[1,2,3]"))).to be_nil
    end
  end

  describe "limitation des tentatives de connexion", type: :request do
    let(:mot_de_passe) { "Password78901$" }
    let!(:compte) { create :compte_admin, email: "moi@exemple.fr", password: mot_de_passe }

    # Rack::Attack est désactivé en test : on l'active ici avec un cache en
    # mémoire, en se plaçant au début d'une fenêtre de comptage.
    around do |exemple|
      cache_initial = Rack::Attack.cache.store
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      Rack::Attack.enabled = true
      Timecop.freeze(Time.utc(2026, 1, 1, 12, 0, 30)) { exemple.run }
    ensure
      Rack::Attack.enabled = false
      Rack::Attack.cache.store = cache_initial
    end

    def tente_connexion(email, password = "mauvais mot de passe")
      post compte_session_path, params: { compte: { email: email, password: password } }
      response
    end

    it "bloque un email après #{Rack::Attack::LIMITE_CONNEXIONS_PAR_EMAIL} tentatives" do
      Rack::Attack::LIMITE_CONNEXIONS_PAR_EMAIL.times do
        expect(tente_connexion("moi@exemple.fr")).not_to have_http_status(:too_many_requests)
      end

      reponse = tente_connexion("moi@exemple.fr", mot_de_passe)
      expect(reponse).to have_http_status(:too_many_requests)
      expect(reponse.body).to include("Trop de tentatives de connexion")
      expect(reponse.headers["retry-after"]).to be_present
    end

    it "compte ensemble les variantes de casse et d'espaces d'un même email" do
      Rack::Attack::LIMITE_CONNEXIONS_PAR_EMAIL.times { tente_connexion(" MOI@exemple.fr ") }

      expect(tente_connexion("moi@exemple.fr")).to have_http_status(:too_many_requests)
    end

    it "ne bloque pas les autres emails" do
      Rack::Attack::LIMITE_CONNEXIONS_PAR_EMAIL.times { tente_connexion("moi@exemple.fr") }

      expect(tente_connexion("autre@exemple.fr")).not_to have_http_status(:too_many_requests)
    end

    it "bloque une IP après #{Rack::Attack::LIMITE_CONNEXIONS_PAR_IP} tentatives, " \
       "même sur des emails différents" do
      Rack::Attack::LIMITE_CONNEXIONS_PAR_IP.times do |i|
        expect(tente_connexion("compte#{i}@exemple.fr"))
          .not_to have_http_status(:too_many_requests)
      end

      expect(tente_connexion("encore@exemple.fr")).to have_http_status(:too_many_requests)
    end

    it "autorise à nouveau la connexion une fois la période écoulée" do
      (Rack::Attack::LIMITE_CONNEXIONS_PAR_EMAIL + 1).times { tente_connexion("moi@exemple.fr") }

      Timecop.freeze(Rack::Attack::PERIODE_CONNEXIONS_PAR_EMAIL.from_now)

      expect(tente_connexion("moi@exemple.fr", mot_de_passe)).to redirect_to(admin_root_path)
    end
  end
end
