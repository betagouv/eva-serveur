require 'rails_helper'

describe ImportExport::Questions::Export do
  let(:question) { create(:question) }
  let(:type) { 'QuestionQcm' }

  include_context 'export'

  describe '#nom_du_fichier' do
    it 'genere le nom du fichier' do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        nom_du_fichier_attendu = '20250228010203-QuestionQcm.xls'
        expect(response_service.nom_du_fichier('QuestionQcm')).to eq(nom_du_fichier_attendu)
      end
    end
  end

  describe '#content_type_xls' do
    it { expect(response_service.content_type_xls).to eq 'application/vnd.ms-excel' }
  end
end
