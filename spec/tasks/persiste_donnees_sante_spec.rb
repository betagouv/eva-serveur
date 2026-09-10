require 'rails_helper'

describe 'donnees_socio_demographique:persiste_donnees_sante' do
  include_context 'rake'

  let(:logger) { RakeLogger.logger }
  let(:situation) { create :situation_bienvenue }
  let(:choix_oui) { create :choix, :bon, nom_technique: 'bienvenue_oui' }
  let(:choix_non) { create :choix, :bon, nom_technique: 'bienvenue_non' }
  let(:entendre) do
    create :question_qcm, nom_technique: 'entendre',
                          categorie: 'sante',
                          libelle: 'Audition',
                          choix: [ choix_oui, choix_non ]
  end
  let(:campagne) { create :campagne }
  let(:evaluation) { create :evaluation, :eva, campagne: campagne }

  before { allow(logger).to receive(:info) }

  def cree_reponse_entendre(partie:, choix:, date:)
    create :evenement_affichage_question_qcm, partie: partie,
                                              donnees: { question: entendre.id },
                                              date: date
    create :evenement_reponse, partie: partie,
                               donnees: { question: entendre.id, reponse: choix.id },
                               date: date + 1.second
  end

  def cree_partie(evaluation:, choix:, created_at:, terminee:)
    partie = create :partie, situation: situation, evaluation: evaluation, created_at: created_at
    create :evenement_demarrage, partie: partie, date: created_at
    cree_reponse_entendre(partie: partie, choix: choix, date: created_at + 1.second)
    create :evenement_fin_situation, partie: partie, date: created_at + 3.seconds if terminee
    partie
  end

  def cree_partie_terminee(evaluation:, choix:, created_at:)
    cree_partie(evaluation: evaluation, choix: choix, created_at: created_at, terminee: true)
  end

  def cree_partie_abandonnee(evaluation:, choix:, created_at:)
    cree_partie(evaluation: evaluation, choix: choix, created_at: created_at, terminee: false)
  end

  context "évaluation avec une seule partie Bienvenue terminée" do
    before { cree_partie_terminee(evaluation: evaluation, choix: choix_oui, created_at: 1.day.ago) }

    it 'persiste les données sociodémographiques' do
      subject.invoke
      expect(evaluation.reload.donnee_sociodemographique.entendre).to eq 'bienvenue_oui'
    end
  end

  context "évaluation avec plusieurs parties Bienvenue terminées" do
    before do
      cree_partie_terminee(evaluation: evaluation, choix: choix_oui, created_at: 2.days.ago)
      cree_partie_terminee(evaluation: evaluation, choix: choix_non, created_at: 1.day.ago)
    end

    it 'ne persiste que la réponse de la partie la plus récente' do
      subject.invoke
      expect(evaluation.reload.donnee_sociodemographique.entendre).to eq 'bienvenue_non'
    end
  end

  context "la partie la plus récente n'est pas terminée mais une plus ancienne l'est" do
    before do
      cree_partie_terminee(evaluation: evaluation, choix: choix_oui, created_at: 2.days.ago)
      cree_partie_abandonnee(evaluation: evaluation, choix: choix_non, created_at: 1.day.ago)
    end

    it "utilise la dernière partie terminée, pas la tentative abandonnée plus récente" do
      subject.invoke
      expect(evaluation.reload.donnee_sociodemographique.entendre).to eq 'bienvenue_oui'
    end
  end

  context "aucune partie Bienvenue n'est terminée" do
    before do
      cree_partie_abandonnee(evaluation: evaluation, choix: choix_oui, created_at: 1.day.ago)
    end

    it "ne crée pas de données sociodémographiques" do
      subject.invoke
      expect(evaluation.reload.donnee_sociodemographique).to be_nil
    end
  end

  context "une partie Bienvenue sans aucun événement" do
    before { create :partie, situation: situation, evaluation: evaluation }

    it "ne lève pas d'erreur" do
      expect { subject.invoke }.not_to raise_error
    end
  end
end
