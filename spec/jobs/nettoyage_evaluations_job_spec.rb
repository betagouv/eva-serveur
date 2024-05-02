# frozen_string_literal: true

require 'rails_helper'

describe NettoyageEvaluationsJob, type: :job do
  let(:situation1) { create(:situation_maintenance) }
  let(:situation2) { create(:situation_controle) }
  let(:structure) { create :structure_locale, nom: Eva::STRUCTURE_DEMO }
  let(:admin) { create :compte_admin, structure: structure }
  let(:campagne) { create :campagne, compte: admin }

  it "Supprime le contenu des évaluations effacées il y a plus d'un mois" do
    deleted_at = 1.month.ago
    evaluation = create :evaluation, nom: 'eval1', campagne: campagne, deleted_at: deleted_at
    partie1 = create :partie, evaluation: evaluation, situation: situation1, deleted_at: deleted_at
    create :partie, evaluation: evaluation, situation: situation2, deleted_at: deleted_at
    create :evenement_demarrage,
           partie: partie1,
           date: Time.zone.local(2019, 10, 9, 10, 1, 20),
           deleted_at: deleted_at
    create :evenement_apparition_mot,
           partie: partie1,
           donnees: { 'mot' => 'revu', 'type' => 'neutre' },
           date: Time.zone.local(2019, 10, 9, 10, 1, 21),
           deleted_at: deleted_at

    NettoyageEvaluationsJob.perform_now

    evaluation = Evaluation.with_deleted.find_by(nom: 'eval1')
    expect(evaluation).not_to be_nil
    expect(Partie.with_deleted.where(evaluation: evaluation).count).to eq(0)
    expect(Evenement.with_deleted.count).to eq(0)
  end

  it "Ne supprime pas le contenu des évaluations effacées il y a moins d'un mois" do
    moins_dun_mois = 1.month.ago + 1.day
    evaluation = create :evaluation, nom: 'eval1', campagne: campagne, deleted_at: moins_dun_mois
    partie1 = create :partie,
                     evaluation: evaluation,
                     situation: situation1,
                     deleted_at: moins_dun_mois
    create :evenement_demarrage,
           partie: partie1,
           date: Time.zone.local(2019, 10, 9, 10, 1, 20),
           deleted_at: moins_dun_mois

    NettoyageEvaluationsJob.perform_now

    evaluation = Evaluation.with_deleted.find_by(nom: 'eval1')
    expect(evaluation).not_to be_nil
    expect(Partie.with_deleted.where(evaluation: evaluation).count).to eq(1)
    expect(Evenement.with_deleted.count).to eq(1)
  end

  it 'Ne supprime pas le contenu des évaluations non éffacées' do
    evaluation = create :evaluation, nom: 'eval1', campagne: campagne, created_at: 1.month.ago
    partie1 = create :partie, evaluation: evaluation, situation: situation1
    create :evenement_demarrage,
           partie: partie1,
           date: Time.zone.local(2019, 10, 9, 10, 1, 20)

    NettoyageEvaluationsJob.perform_now

    evaluation = Evaluation.find_by(nom: 'eval1')
    expect(evaluation).not_to be_nil
    expect(Partie.with_deleted.where(evaluation: evaluation).count).to eq(1)
    expect(Evenement.count).to eq(1)
  end
end
