# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Bienvenue do
  let(:choix_france) { create :choix, :bon, nom_technique: 'france' }
  let(:quel_age) do
    create :question_saisie, nom_technique: 'age',
                             categorie: 'situation',
                             libelle: 'quel age ?'
  end
  let(:scolarite) do
    create :question_qcm, nom_technique: 'lieu_scolarite',
                          categorie: 'scolarite',
                          libelle: 'lieu de scolarité',
                          choix: [choix_france]
  end
  let(:situation) { create :situation_bienvenue }
  let(:evenements) { [] }
  let(:questionnaire) { create :questionnaire, questions: [quel_age, scolarite] }
  let(:campagne) { Campagne.new }

  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:evenements) do
    [
      build(:evenement_demarrage, partie: partie),
      build(:evenement_affichage_question_qcm, donnees: { question: quel_age.id },
                                               date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
      build(:evenement_reponse, donnees: { question: quel_age.id,
                                           reponse: '33' },
                                date: Time.zone.local(2019, 10, 9, 10, 1, 22)),
      build(:evenement_affichage_question_qcm, donnees: { question: scolarite.id },
                                               date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
      build(:evenement_reponse, donnees: { question: scolarite.id,
                                           reponse: choix_france.id },
                                date: Time.zone.local(2019, 10, 9, 10, 1, 22))
    ]
  end

  let(:restitution) { described_class.new campagne, evenements }

  before do
    allow(campagne).to receive(:questionnaire_pour).and_return(questionnaire)
  end

  describe '#persiste' do
    context 'persiste de nouvelles données sociodémographiques' do
      let(:evaluation) { create :evaluation, campagne: campagne }

      it do
        restitution.persiste
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context 'met à jour les données sociodémographiques' do
      let(:evaluation) { create :evaluation, :avec_donnee_sociodemographique, campagne: campagne }

      it do
        donnees = evaluation.donnee_sociodemographique
        expect(donnees.age).to eq 25
        expect(donnees.genre).to eq 'homme'
        expect(donnees.lieu_scolarite).to eq 'non_scolarise'

        restitution.persiste

        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
        expect(donnees.genre).to eq 'homme'
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context 'restaure et met à jour des données sociodémographiques effacées' do
      let(:evaluation) { create :evaluation, :avec_donnee_sociodemographique, campagne: campagne }

      it do
        donnees = evaluation.donnee_sociodemographique
        donnees.delete

        restitution.persiste

        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
        expect(donnees.genre).to eq 'homme'
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end
  end

  describe '#inclus_autopositionnement?' do
    let(:evaluation) { create :evaluation, campagne: campagne }

    context 'avec le questionnaire autopositionnement' do
      let(:questionnaire) { create :questionnaire, :autopositionnement }

      before do
        allow(campagne).to receive(:questionnaire_pour).and_return(questionnaire)
      end

      it 'retourne true' do
        expect(restitution.inclus_autopositionnement?).to be true
      end
    end

    context 'avec un questionnaire sociodemographique_autopositionnement' do
      let(:questionnaire) { create :questionnaire, :sociodemographique_autopositionnement }

      before do
        allow(campagne).to receive(:questionnaire_pour).and_return(questionnaire)
      end

      it 'retourne true' do
        expect(restitution.inclus_autopositionnement?).to be true
      end
    end

    context 'avec une autre questionnaire' do
      it 'retourne false' do
        expect(restitution.inclus_autopositionnement?).to be false
      end
    end
  end

  describe '#questionnaires_questions_pour' do
    let(:evaluation) { create :evaluation, campagne: campagne }

    it 'retourne les questionnaires questions pour une catégorie donnée' do
      expect(restitution.questionnaires_questions_pour('situation').count).to eq 1
      expect(restitution.questionnaires_questions_pour('situation').first.question).to eq quel_age
      expect(restitution.questionnaires_questions_pour('scolarite').count).to eq 1
      expect(restitution.questionnaires_questions_pour('scolarite').first.question).to eq scolarite
    end
  end
end
