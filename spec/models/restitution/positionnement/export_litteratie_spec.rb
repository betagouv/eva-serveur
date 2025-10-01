require 'rails_helper'

describe Restitution::Positionnement::ExportLitteratie do
  subject(:service) do
    described_class.new(partie, onglet_xls)
  end

  let(:questions) { [] }
  let(:questionnaire) { create :questionnaire, questions: questions }
  let(:situation) { create :situation, questionnaire: questionnaire }
  let(:partie) { create :partie, situation: situation }
  let(:export) { ImportExport::ExportXls.new }
  let(:onglet_xls) do
    entetes = ImportExport::Positionnement::ExportDonnees.new(partie).entetes
    export.cree_worksheet_donnees(entetes)
  end
  let(:spreadsheet) { export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }

  describe '#new' do
    it 'crée des évènements questions à partir des évènements' do
      create :evenement_reponse, partie: partie,
                                 donnees: {
                                   question: 'LOdi1'
                                 }

      evenements_questions = service.evenements_questions

      expect(evenements_questions.size).to eq(1)
      expect(evenements_questions.first.nom_technique).to eq('LOdi1')
    end
  end
end
