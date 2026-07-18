require "rails_helper"

RSpec.describe Admin::Evaluations::XlsConfiguration do
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
