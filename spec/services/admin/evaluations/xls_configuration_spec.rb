require "rails_helper"

RSpec.describe Admin::Evaluations::XlsConfiguration do
  describe "#colonnes_pour" do
    let(:configuration) { described_class.new }
    let(:compte_entreprise) { instance_double(Compte, utilisateur_entreprise?: true) }
    let(:compte_hors_entreprise) { instance_double(Compte, utilisateur_entreprise?: false) }

    it "retourne les colonnes de l export eva pro" do
      expect(configuration.colonnes_pour(compte: compte_entreprise)).to eq(
        described_class::COLONNES_COMMUNES + described_class::COLONNES_EVA_PRO
      )
    end

    it "retourne les colonnes de l export hors eva pro" do
      expect(configuration.colonnes_pour(compte: compte_hors_entreprise)).to eq(
        described_class::COLONNES_COMMUNES + described_class::COLONNES_HORS_EVA_PRO
      )
    end
  end

  describe "#colonne_visible?" do
    let(:configuration) { described_class.new }
    let(:compte_entreprise) { instance_double(Compte, utilisateur_entreprise?: true) }
    let(:compte_hors_entreprise) { instance_double(Compte, utilisateur_entreprise?: false) }

    it "indique qu une colonne eva pro est visible pour un compte entreprise" do
      expect(configuration.colonne_visible?(:taux_risque, compte: compte_entreprise)).to be(true)
    end

    it "indique qu une colonne eva pro est masquee pour un compte hors eva pro" do
      expect(configuration.colonne_visible?(:taux_risque,
compte: compte_hors_entreprise)).to be(false)
    end
  end

  describe "#masquer_colonnes_non_visibles" do
    let(:configuration) { described_class.new }
    let(:sheet) { instance_double(Spreadsheet::Worksheet) }
    let(:compte_entreprise) { instance_double(Compte, utilisateur_entreprise?: true) }
    let(:compte_hors_entreprise) { instance_double(Compte, utilisateur_entreprise?: false) }
    let(:sheet_columns) do
      Array.new(described_class::COLONNES_DANS_ORDRE_EXPORT.size) { instance_double(Spreadsheet::Column) }
    end

    before do
      allow(sheet).to receive(:column) { |index| sheet_columns[index] }
      sheet_columns.each { |column| allow(column).to receive(:hidden=) }
    end

    it "masque niveau_cefr et laisse securite_qualite visible pour un compte eva pro" do
      configuration.masquer_colonnes_non_visibles(sheet: sheet, compte: compte_entreprise)

      expect(sheet_columns[8]).to have_received(:hidden=).with(true)
      expect(sheet_columns[18]).not_to have_received(:hidden=)
    end

    it "masque securite_qualite et laisse niveau_cefr visible pour un compte hors eva pro" do
      configuration.masquer_colonnes_non_visibles(sheet: sheet, compte: compte_hors_entreprise)

      expect(sheet_columns[18]).to have_received(:hidden=).with(true)
      expect(sheet_columns[8]).not_to have_received(:hidden=)
    end
  end

  describe "#appliquer_limite!" do
    let(:configuration) { described_class.new }
    let(:sheet) { instance_double(Spreadsheet::Worksheet) }
    let(:collection) { instance_double(ActiveRecord::Relation) }

    context "quand la collection depasse la limite" do
      it "ajoute le message et tronque la collection" do
        limite = ImportExport::ExportXls::NOMBRE_MAX_LIGNES
        allow(collection).to receive(:count).and_return(limite + 1)
        expect(sheet).to receive(:<<).with(
          [ I18n.t("active_admin.export.limite_atteinte",
limite: ImportExport::ExportXls::NOMBRE_MAX_LIGNES) ]
        )
        expect(collection).to receive(:limit!)
          .with(ImportExport::ExportXls::NOMBRE_MAX_LIGNES)
          .and_return(:collection_limitee)

        result = configuration.appliquer_limite!(sheet: sheet, collection: collection)

        expect(result).to eq(:collection_limitee)
      end
    end

    context "quand la collection ne depasse pas la limite" do
      it "retourne la collection sans la modifier" do
        allow(collection).to receive(:count).and_return(ImportExport::ExportXls::NOMBRE_MAX_LIGNES)
        expect(sheet).not_to receive(:<<)
        expect(collection).not_to receive(:limit!)

        result = configuration.appliquer_limite!(sheet: sheet, collection: collection)

        expect(result).to eq(collection)
      end
    end
  end
end
