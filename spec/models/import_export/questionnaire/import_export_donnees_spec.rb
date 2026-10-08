require 'rails_helper'

describe ImportExport::Questionnaire::ImportExportDonnees do
  describe '#exporte_donnees' do
    it "nomme le fichier d'après le nom technique du questionnaire" do
      questionnaire = create(:questionnaire, nom_technique: 'mon_questionnaire')

      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        export = described_class.new(questionnaires: questionnaire).exporte_donnees
        expect(export[:filename]).to eq('20250228010203-questionnaire-mon_questionnaire.xls')
      end
    end

    it 'nomme le fichier de manière générique quand il y a plusieurs questionnaires' do
      questionnaires = create_list(:questionnaire, 2)

      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        export = described_class.new(questionnaires: questionnaires).exporte_donnees
        expect(export[:filename]).to eq('20250228010203-questionnaires.xls')
      end
    end
  end
end
