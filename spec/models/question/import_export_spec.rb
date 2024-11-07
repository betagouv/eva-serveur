# frozen_string_literal: true

require 'rails_helper'

describe Question::ImportExport do
  subject(:service) do
    described_class.new(question)
  end

  describe '#exporte_donnees' do
    let!(:question) { create(:question_clic_dans_image) }

    it 'exporte les données' do
      date = DateTime.current.strftime('%Y%m%d')
      nom_du_fichier_attendu = "#{date}-#{question.nom_technique}.xls"
      expect(service.exporte_donnees[:xls]).not_to be_nil
      expect(service.exporte_donnees[:content_type]).to eq 'application/vnd.ms-excel'
      expect(service.exporte_donnees[:filename]).to eq nom_du_fichier_attendu
    end
  end

  describe '#importe_donnees' do
    let(:question) { create(:question_clic_dans_image) }
    let!(:file) do
      fixture_file_upload('spec/support/import_question_clic.xls', 'text/xls')
    end

    it 'importe une nouvelle question' do
      expect(Question.count).to eq 0
      expect do
        service.importe_donnees(file)
      end.to change(Question, :count).by(1)
    end
  end
end
