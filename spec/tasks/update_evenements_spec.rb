# frozen_string_literal: true

require 'rails_helper'

describe 'evenements:update_questions_reponses' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  let(:situation) { create :situation_bienvenue }
  let!(:partie) { create :partie, situation: situation }
  let!(:ancienne_question) { create :question_qcm, nom_technique: 'confondre_objets' }
  let!(:nouvelle_question) { create :question_qcm, nom_technique: 'differencier_objets' }
  let!(:reponse) do
    create :choix, :bon, question_id: ancienne_question.id, nom_technique: 'bienvenue_daccord'
  end
  let!(:nouvelle_reponse) do
    create :choix, :bon, question_id: nouvelle_question.id, nom_technique: 'pas_daccord'
  end
  let!(:evenement) do
    create(:evenement_reponse, partie: partie,
                               donnees: { question: ancienne_question.id, reponse: reponse.id })
  end
  let!(:evenement_affiche_question) do
    create(:evenement, partie: partie, nom: 'affichageQuestionQCM',
                       donnees: { question: ancienne_question.id })
  end

  before do
    allow(logger).to receive :info
    subject.invoke
  end

  it 'met à jour les évènements réponses de la questions confondre_objets' do
    evenement.reload
    expect(evenement.nom).to eq 'reponse'
    expect(evenement.donnees['question']).to eq(nouvelle_question.id)
    expect(evenement.donnees['reponse']).to eq(nouvelle_reponse.id)
  end

  it 'met à jour les autres évènements' do
    evenement_affiche_question.reload
    expect(evenement_affiche_question.nom).to eq 'affichageQuestionQCM'
    expect(evenement_affiche_question.reload.donnees['question']).to eq(nouvelle_question.id)
  end

  it 'met à jour les noms techniques des choix de la nouvelle question' do
    expect(nouvelle_question.reload.choix.first.nom_technique).to eq('bienvenue_pas_daccord')
  end
end
