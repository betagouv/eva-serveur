# frozen_string_literal: true

require 'rails_helper'

describe EvenementQuestion, type: :model do
  describe '.prises_en_compte_pour_calcul_score_clea' do
    let(:question_n1) { build(:question, :numeratie_niveau1) }
    let(:question_n2) { build(:question, :numeratie_niveau2) }
    let(:question_n3) { build(:question, :numeratie_niveau3) }
    let(:question_rattrapage_n1) { build(:question, :numeratie_niveau1_rattrapage) }
    let(:question_rattrapage_n3) { build(:question, :numeratie_niveau3_rattrapage) }

    let(:evenement_n1) do
      evenement = build(:evenement, donnees: { score: 1, question: question_n1.nom_technique })
      allow(evenement).to receive(:persisted?).and_return(true)
      evenement
    end
    let(:evenement_n2) do
      evenement = build(:evenement, donnees: { score: 2, question: question_n2.nom_technique })
      allow(evenement).to receive(:persisted?).and_return(true)
      evenement
    end
    let(:evenement_n3) do
      evenement = build(:evenement, donnees: { score: 0, question: question_n3.nom_technique })
      allow(evenement).to receive(:persisted?).and_return(true)
      evenement
    end
    let(:evenement_rattrapage_n3) do
      evenement = build(:evenement,
                        donnees: { score: 2, question: question_rattrapage_n3.nom_technique })
      allow(evenement).to receive(:persisted?).and_return(true)
      evenement
    end

    let(:evenement_question_n1) do
      described_class.new(question: question_n1, evenement: evenement_n1)
    end
    let(:evenement_question_n2) do
      described_class.new(question: question_n2, evenement: evenement_n2)
    end
    let(:evenement_question_n3) do
      described_class.new(question: question_n3, evenement: evenement_n3)
    end
    let(:evenement_question_rattrapage_n3) do
      described_class.new(question: question_rattrapage_n3, evenement: evenement_rattrapage_n3)
    end

    let(:evenements_questions) { [] }

    context 'quand plusieurs niveaux ont été joués' do
      let(:evenements_questions) { [ evenement_question_n1, evenement_question_n2 ] }

      it 'ne garde que les questions du dernier niveau atteint' do
        resultat = described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)
        expect(resultat).to contain_exactly(evenement_question_n1, evenement_question_n2)
      end
    end

    context 'quand aucun niveau n\'a été joué' do
      let(:evenements_questions) { [ evenement_question_n3 ] }

      it 'retourne toutes les questions principales car aucun niveau ne peut être déterminé' do
        resultat = described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)
        expect(resultat).to contain_exactly(evenement_question_n3)
      end
    end

    context 'quand une question principale est réussie' do
      let(:evenements_questions) { [ evenement_question_n1 ] }

      it 'ignore la question de rattrapage' do
        resultat = described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)
        expect(resultat).to contain_exactly(evenement_question_n1)
      end
    end

    context 'quand une question principale a échoué' do
      let(:evenements_questions) { [ evenement_question_n3, evenement_question_rattrapage_n3 ] }

      it 'prend en compte la question de rattrapage' do
        resultat = described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)
        expect(resultat).to include(evenement_question_n3, evenement_question_rattrapage_n3)
      end
    end

    context 'quand on a joué uniquement le niveau 1 et 2 mais pas le niveau 3' do
      let(:evenement_question_n3) { described_class.new(question: question_n3, evenement: nil) }
      let(:evenements_questions) do
        [ evenement_question_n1, evenement_question_n2, evenement_question_n3 ]
      end

      it 'ne garde que les questions des niveaux 1 et 2 et exclut le niveau 3' do
        resultat = described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)

        expect(resultat).to include(evenement_question_n1, evenement_question_n2,
                                    evenement_question_n3)
      end
    end
  end

  describe '#reponse' do
    let(:choix1) { create :choix, :bon, nom_technique: 'choix_1', intitule: '' }

    let(:question_qcm) { create(:question_qcm, choix: [ choix1 ]) }
    let(:evenement_question_n1) do
      described_class.new(question: question_qcm, evenement: evenement_n1)
    end

    context 'avec un envenement qui a un intitulé de réponse' do
      let(:evenement_n1) do
        build(:evenement, donnees: { score: 1, reponseIntitule: 'la réponse du bénéficaire' })
      end

      it { expect(evenement_question_n1.reponse).to eq('la réponse du bénéficaire') }
    end

    context 'avec un envenement sans intitulé de réponse' do
      let(:evenement_n1) do
        build(:evenement, donnees: { score: 1, question: question_qcm, reponse: choix1.id })
      end

      it { expect(evenement_question_n1.reponse).to eq('choix_1') }
    end

    context 'avec un envenement avec un intitulé de réponse vide' do
      let(:evenement_n1) do
        build(:evenement, donnees: { score: 1, question: question_qcm,
                                     reponse: choix1.id, reponseIntitule: '' })
      end

      it { expect(evenement_question_n1.reponse).to eq('choix_1') }
    end
  end

  describe '.pour_code_clea' do
    let(:code) { '2.1' }
    let(:sous_code) { '2.1.1' }

    let(:metacompetence_numeratie) do
      Metacompetence::CORRESPONDANCES_CODECLEA[code][sous_code].first
    end
    let(:question_attendue) do
      nom_technique = QuestionData.find_by(
        metacompetence: metacompetence_numeratie
      ).nom_technique
      build(:question, nom_technique: nom_technique)
    end

    let(:evenement_question_attendue) { described_class.new(question: question_attendue) }

    let(:autre_metacompetence) { Metacompetence::CORRESPONDANCES_CODECLEA[code]['2.1.2'].first }
    let(:autre_question) do
      nom_technique = QuestionData.find_by(metacompetence: autre_metacompetence).nom_technique
      build(:question, nom_technique: nom_technique)
    end
    let(:evenement_question_autre) { described_class.new(question: autre_question) }

    let(:evenements_questions) { [ evenement_question_attendue, evenement_question_autre ] }

    it 'retourne les questions du sous-code' do
      expect(described_class.pour_code_clea(evenements_questions,
                                            sous_code)).to eq([ evenement_question_attendue ])
    end

    it 'retourne les questions du code Cléa entier' do
      expect(described_class.pour_code_clea(evenements_questions,
                                            code)).to eq([ evenement_question_attendue,
                                                          evenement_question_autre ])
    end
  end

  describe '.construit_pour' do
    let(:question1) {
 instance_double(Question, nom_technique: "Q1", nom_technique_sans_variant: "Q1", type: "normal") }
    let(:question_variant) {
 instance_double(Question, nom_technique: "Q2__variant", nom_technique_sans_variant: "Q2",
type: "normal") }
    let(:question_sous_consigne) {
 instance_double(Question, nom_technique: "Q3", type: QuestionSousConsigne::QUESTION_TYPE) }

    let(:evenement_valide1) {
 instance_double(Evenement, reponse?: true, question_nom_technique: "Q1",
donnees: { "succes" => true }) }
    let(:evenement_valide_variant) {
 instance_double(Evenement, reponse?: true, question_nom_technique: "Q2",
donnees: { "succes" => true }) }
    let(:evenement_non_reponse) {
 instance_double(Evenement, reponse?: false, question_nom_technique: "Q3",
donnees: { "succes" => true }) }

    let(:evenements) { [ evenement_valide1, evenement_valide_variant, evenement_non_reponse ] }
    let(:questions) { [ question1, question_variant, question_sous_consigne ] }

    it "doit retourner un array d'EvenementQuestion" do
      resultat = described_class.construit_pour(evenements, questions)

      expect(resultat).to all(be_a(described_class))
    end

    it "exclue les evenements qui ne sont pas des réponse" do
      resultat = described_class.construit_pour(evenements, questions)

      expect(resultat.map(&:nom_technique)).not_to include("Q3")
    end

    it "exclue les questions qui sont des sous consigne" do
      resultat = described_class.construit_pour(evenements, questions)

      noms_techniques = resultat.map(&:nom_technique)
      expect(noms_techniques).to include("Q1", "Q2__variant")
      expect(noms_techniques).not_to include("Q3")
    end

    it "utilise nom_technique_sans_variant pour les questions variants" do
      resultat = described_class.construit_pour(evenements, questions)

      expect(resultat.all? { |eq| eq.succes == true }).to be true
    end
  end
end
