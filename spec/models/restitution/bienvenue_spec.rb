require 'rails_helper'

describe Restitution::Bienvenue do
  let(:choix_france) { create :choix, :bon, nom_technique: 'france' }
  let(:choix_bienvenue_oui) { create :choix, :bon, nom_technique: 'bienvenue_oui' }
  let(:quel_age) do
    create :question_saisie, nom_technique: 'age',
                             categorie: 'situation',
                             libelle: 'quel age ?',
                             type_saisie: :numerique
  end
  let(:scolarite) do
    create :question_qcm, nom_technique: 'lieu_scolarite',
                          categorie: 'scolarite',
                          libelle: 'lieu de scolarité',
                          choix: [ choix_france ]
  end
  let(:entendre) do
    create :question_qcm, nom_technique: 'entendre',
                          categorie: 'sante',
                          libelle: 'Audition',
                          choix: [ choix_bienvenue_oui ]
  end
  let(:situation) { create :situation_bienvenue }
  let(:questionnaire) { create :questionnaire, questions: [ quel_age, scolarite ] }
  let(:campagne) { Campagne.new }

  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let!(:age) { '33' }
  let(:evenements) do
    [
      build(:evenement_demarrage, partie: partie),
      build(:evenement_affichage_question_qcm, donnees: { question: quel_age.id },
                                               date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
      build(:evenement_reponse, donnees: { question: quel_age.id,
                                           reponse: age },
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
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }

      it do
        restitution.persiste
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context 'met à jour les données sociodémographiques' do
      let(:evaluation) {
        create :evaluation, :eva, :avec_donnee_sociodemographique, campagne: campagne
      }

      it do
        donnees = evaluation.donnee_sociodemographique
        expect(donnees.age).to eq 25
        expect(donnees.genre).to eq 'homme'
        expect(donnees.lieu_scolarite).to eq 'non'

        restitution.persiste

        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
        expect(donnees.genre).to eq 'homme'
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context 'restaure et met à jour des données sociodémographiques effacées' do
      let(:evaluation) {
        create :evaluation, :eva, :avec_donnee_sociodemographique, campagne: campagne
      }

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

    context "Cas d'un age avec un entier trop grand" do
      let(:age) { '2147483648' }
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }

      it do
        restitution.persiste
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to be_nil
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context "Cas d'un age avec maximum" do
      let(:age) { '2147483647' }
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }

      it do
        restitution.persiste
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 2_147_483_647
        expect(donnees.lieu_scolarite).to eq 'france'
      end
    end

    context 'persiste les données de santé' do
      let(:questionnaire) { create :questionnaire, questions: [ quel_age, scolarite, entendre ] }
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }
      let(:evenements) do
        [
          build(:evenement_demarrage, partie: partie),
          build(:evenement_affichage_question_qcm, donnees: { question: quel_age.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: quel_age.id, reponse: age },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22)),
          build(:evenement_affichage_question_qcm, donnees: { question: entendre.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 23)),
          build(:evenement_reponse, donnees: { question: entendre.id,
                                               reponse: choix_bienvenue_oui.id },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 24))
        ]
      end

      it 'enregistre la réponse sur la colonne correspondante' do
        restitution.persiste
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.entendre).to eq 'bienvenue_oui'
      end
    end

    context 'ignore une question santé dont le nom technique ne correspond à aucune colonne' do
      let(:choix_inconnu) { create :choix, :bon, nom_technique: 'oui' }
      let(:question_inconnue) do
        create :question_qcm, nom_technique: 'nouvelle_question_sante',
                              categorie: 'sante',
                              libelle: 'Nouvelle question',
                              choix: [ choix_inconnu ]
      end
      let(:questionnaire) { create :questionnaire, questions: [ quel_age, question_inconnue ] }
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }
      let(:evenements) do
        [
          build(:evenement_demarrage, partie: partie),
          build(:evenement_affichage_question_qcm, donnees: { question: quel_age.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: quel_age.id, reponse: age },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22)),
          build(:evenement_affichage_question_qcm, donnees: { question: question_inconnue.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 23)),
          build(:evenement_reponse, donnees: { question: question_inconnue.id,
                                               reponse: choix_inconnu.id },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 24))
        ]
      end

      it "ne lève pas d'erreur et n'enregistre pas la réponse" do
        expect { restitution.persiste }.not_to raise_error
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
      end
    end

    context "une réponse référence une question supprimée entre-temps" do
      let(:questionnaire) { create :questionnaire, questions: [ quel_age, scolarite ] }
      let(:evaluation) { create :evaluation, :eva, campagne: campagne }
      let(:evenements) do
        [
          build(:evenement_demarrage, partie: partie),
          build(:evenement_affichage_question_qcm, donnees: { question: quel_age.id },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
          build(:evenement_reponse, donnees: { question: quel_age.id, reponse: age },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 22)),
          build(:evenement_affichage_question_qcm, donnees: { question: SecureRandom.uuid },
                                                   date: Time.zone.local(2019, 10, 9, 10, 1, 23)),
          build(:evenement_reponse, donnees: { question: SecureRandom.uuid,
                                               reponse: 'oui' },
                                    date: Time.zone.local(2019, 10, 9, 10, 1, 24))
        ]
      end

      it "ne lève pas d'erreur et persiste les autres réponses" do
        expect { restitution.persiste }.not_to raise_error
        donnees = evaluation.reload.donnee_sociodemographique
        expect(donnees.age).to eq 33
      end
    end
  end

  describe '#inclus_autopositionnement?' do
    let(:evaluation) { create :evaluation, campagne: campagne }

    before do
      allow(campagne).to receive(:questionnaire_pour).and_return(questionnaire)
    end

    context 'avec le questionnaire autopositionnement' do
      let(:questionnaire) { create :questionnaire, :autopositionnement }

      it { expect(restitution.inclus_autopositionnement?).to be true }
    end

    context 'avec un questionnaire sociodemographique_autopositionnement' do
      let(:questionnaire) { create :questionnaire, :sociodemographique_autopositionnement }

      it { expect(restitution.inclus_autopositionnement?).to be true }
    end

    context 'avec un questionnaire sociodemographique_autopositionnement_sante' do
      let(:questionnaire) { create :questionnaire, :sociodemographique_autopositionnement_sante }

      it { expect(restitution.inclus_autopositionnement?).to be true }
    end

    context 'avec une autre questionnaire' do
      it { expect(restitution.inclus_autopositionnement?).to be false }
    end
  end

  describe '#inclus_sante?' do
    let(:evaluation) { create :evaluation, campagne: campagne }

    before do
      allow(campagne).to receive(:questionnaire_pour).and_return(questionnaire)
    end

    context 'avec un questionnaire sociodemographique_sante' do
      let(:questionnaire) { create :questionnaire, :sociodemographique_sante }

      it { expect(restitution.inclus_sante?).to be true }
    end

    context 'avec un questionnaire sociodemographique_autopositionnement_sante' do
      let(:questionnaire) { create :questionnaire, :sociodemographique_autopositionnement_sante }

      it { expect(restitution.inclus_sante?).to be true }
    end

    context 'avec une autre questionnaire' do
      it { expect(restitution.inclus_sante?).to be false }
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
