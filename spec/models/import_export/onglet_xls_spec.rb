# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::OngletXls do
  describe '#set_nombre(ligne, colonne, valeur)' do
    let(:onglet_xls) do
      entetes = [{ titre: 'Mon titre', taille: 20 }]
      workbook = Spreadsheet::Workbook.new
      described_class.new(ImportExport::ExportXls::WORKSHEET_DONNEES, workbook, entetes)
    end

    context 'quand le nombre est un entier' do
      let(:valeur) { 1 }

      it 'utilise un format de nombre entier' do
        ligne = 1
        colonne = 0

        expect(onglet_xls).to receive(:set_format_colonne).with(
          ligne,
          colonne,
          ImportExport::OngletXls::NUMBER_FORMAT
        )

        onglet_xls.set_nombre(ligne, colonne, valeur)
      end
    end

    context 'quand le nombre est un décimal' do
      let(:valeur) { 0.5 }

      it 'utilise un format de nombre décimal' do
        ligne = 1
        colonne = 0

        expect(onglet_xls).to receive(:set_format_colonne).with(
          ligne,
          colonne,
          ImportExport::OngletXls::DECIMAL_NUMBER_FORMAT
        )

        onglet_xls.set_nombre(ligne, colonne, valeur)
      end
    end
  end
end
