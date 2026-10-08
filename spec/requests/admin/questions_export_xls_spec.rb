require 'rails_helper'

describe 'Admin - Export XLS de la liste des questions', type: :request do
  before { sign_in create(:compte_superadmin) }

  def feuille_exportee
    Spreadsheet.open(StringIO.new(response.body)).worksheet(0)
  end

  {
    question_clic_dans_image: :admin_questions_clic_dans_image_path,
    question_clic_dans_texte: :admin_questions_clic_dans_texte_path,
    question_glisser_deposer: :admin_questions_glisser_deposer_path,
    question_qcm: :admin_question_qcms_path,
    question_saisie: :admin_questions_saisies_path,
    question_sous_consigne: :admin_question_sous_consignes_path
  }.each do |factory, chemin|
    it "exporte les #{factory} au format d'import" do
      question = create factory
      type = question.type

      get send(chemin, format: :xls)

      entetes = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type]
      expect(feuille_exportee.row(0).to_a).to eq(entetes.map { |entete| entete.to_s.humanize })
      expect(feuille_exportee.row(1)[1]).to eq question.nom_technique
      expect(response.headers['Content-Disposition']).to include "-#{type}.xls"
    end
  end

  it 'exporte uniquement les questions filtrées' do
    create :question_qcm, nom_technique: 'gardee'
    create :question_qcm, nom_technique: 'ecartee'

    get admin_question_qcms_path(format: :xls, q: { nom_technique_cont: 'gardee' })

    expect(feuille_exportee.column(1).to_a.drop(1)).to eq [ 'gardee' ]
  end
end
