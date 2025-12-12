require "rails_helper"

describe EtapeInscription do
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include EtapeInscription

      attr_accessor :etape_inscription, :structure, :id_pro_connect, :siret_pro_connect

      def update(attributes)
        attributes.each do |key, value|
          send("#{key}=", value)
        end
        true
      end
    end
  end

  describe "#termine_preinscription!" do
    context "quand l'étape n'est pas preinscription" do
      it "ne change pas l'étape si elle est 'nouveau'" do
        objet = test_class.new(etape_inscription: "nouveau")
        objet.termine_preinscription!
        expect(objet.etape_inscription).to eq("nouveau")
      end

      it "ne change pas l'étape si elle est 'complet'" do
        objet = test_class.new(etape_inscription: "complet")
        objet.termine_preinscription!
        expect(objet.etape_inscription).to eq("complet")
      end

      it "ne change pas l'étape si elle est 'recherche_structure'" do
        objet = test_class.new(etape_inscription: "recherche_structure")
        objet.termine_preinscription!
        expect(objet.etape_inscription).to eq("recherche_structure")
      end
    end
  end

  describe "#etape_inscription_nouveau?" do
    it "retourne true quand l'étape est 'nouveau'" do
      objet = test_class.new(etape_inscription: "nouveau")
      expect(objet.etape_inscription_nouveau?).to be(true)
    end

    it "retourne false quand l'étape n'est pas 'nouveau'" do
      objet = test_class.new(etape_inscription: "preinscription")
      expect(objet.etape_inscription_nouveau?).to be(false)
    end
  end

  describe "#etape_inscription_preinscription?" do
    it "retourne true quand l'étape est 'preinscription'" do
      objet = test_class.new(etape_inscription: "preinscription")
      expect(objet.etape_inscription_preinscription?).to be(true)
    end

    it "retourne false quand l'étape n'est pas 'preinscription'" do
      objet = test_class.new(etape_inscription: "nouveau")
      expect(objet.etape_inscription_preinscription?).to be(false)
    end
  end

  describe "#doit_completer_inscription?" do
    it "retourne true quand l'étape n'est pas 'complet'" do
      objet = test_class.new(etape_inscription: "nouveau")
      expect(objet.doit_completer_inscription?).to be(true)
    end

    it "retourne false quand l'étape est 'complet'" do
      objet = test_class.new(etape_inscription: "complet")
      expect(objet.doit_completer_inscription?).to be(false)
    end
  end

  describe "#assigne_preinscription" do
    context "quand l'étape est 'nouveau'" do
      it "change l'étape à 'preinscription'" do
        objet = test_class.new(etape_inscription: "nouveau")
        objet.assigne_preinscription
        expect(objet.etape_inscription).to eq("preinscription")
      end
    end

    context "quand l'étape n'est pas 'nouveau'" do
      it "ne change pas l'étape si elle est 'preinscription'" do
        objet = test_class.new(etape_inscription: "preinscription")
        objet.assigne_preinscription
        expect(objet.etape_inscription).to eq("preinscription")
      end

      it "ne change pas l'étape si elle est 'complet'" do
        objet = test_class.new(etape_inscription: "complet")
        objet.assigne_preinscription
        expect(objet.etape_inscription).to eq("complet")
      end
    end
  end
end
