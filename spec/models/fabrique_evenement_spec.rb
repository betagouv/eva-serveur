# frozen_string_literal: true

require 'rails_helper'

describe FabriqueEvenement do
  ActiveJob::Base.queue_adapter = :test
  let!(:situation_livraison) { create :situation_livraison }

  let(:chemin) { Rails.root.join('spec/support/evenement/donnees.json') }
  let(:donnees) { JSON.parse(File.read(chemin)) }
  let(:evaluation) { create :evaluation }
  let(:nom_evenement) { 'finSituation' }
  let(:parametres) do
    ActionController::Parameters.new(
      date: 1_631_891_703_815,
      donnees: {},
      nom: nom_evenement,
      position: 0,
      session_id: '184e1079-3bb9-4229-921e-4c2574d94934',
      situation: situation_livraison.nom_technique,
      evaluation_id: evaluation.id
    )
  end

  describe '#call' do
    it 'crée une partie et un évènement' do
      expect do
        FabriqueEvenement.new(parametres).call
      end.to change(Partie, :count)
        .by(1)
        .and change(Evenement, :count)
        .by(1)
    end

    it "retourne l'évènement" do
      expect(FabriqueEvenement.new(parametres).call).to be_an_instance_of Evenement
    end

    context "quand l'évènement est une fin de situation" do
      let(:nom_evenement) { 'finSituation' }

      it 'programme un job pour assigner les métriques à la partie' do
        expect do
          FabriqueEvenement.new(parametres).call
        end.to have_enqueued_job(PersisteMetriquesPartieJob).exactly(1)
      end
    end

    context "Quand l'évènement n'est pas une fin de situation" do
      let(:nom_evenement) { 'autre' }

      it 'ne programme pas de job pour assigner les métriques à la partie' do
        expect do
          FabriqueEvenement.new(parametres).call
        end.to have_enqueued_job(PersisteMetriquesPartieJob).exactly(0)
      end
    end

    context 'quand une partie est déjà existante' do
      let!(:partie) do
        create :partie, session_id: '184e1079-3bb9-4229-921e-4c2574d94934',
                        situation: situation_livraison,
                        evaluation: evaluation
      end

      it 'crée un évènement' do
        expect do
          FabriqueEvenement.new(parametres).call
        end.to change(Partie, :count)
          .by(0)
          .and change(Evenement, :count)
          .by(1)
        expect(Evenement.last.partie).to eq partie
      end
    end

    context "quand l'id de l'évaluation est invalide" do
      let(:parametres_invalide) do
        ActionController::Parameters.new(
          date: 1_631_891_703_815,
          donnees: {},
          nom: 'finSituation',
          position: 0,
          session_id: '184e1079-3bb9-4229-921e-4c2574d94934',
          situation: situation_livraison.nom_technique,
          evaluation_id: nil
        )
      end

      it 'ne crée rien' do
        expect do
          FabriqueEvenement.new(parametres_invalide).call
        end.to change(Partie, :count)
          .by(0)
          .and change(Evenement, :count)
          .by(0)
      end
    end

    context "quand la création de l'évènement échoue" do
      let(:parametres_invalide) do
        ActionController::Parameters.new(
          date: nil,
          nom: 'finSituation',
          situation: 'livraison',
          session_id: 'O8j78U2xcb2',
          donnees: donnees,
          evaluation_id: evaluation.id
        )
      end

      it 'la partie est quand même créée' do
        expect do
          FabriqueEvenement.new(parametres_invalide).call
        end.to change(Partie, :count)
          .by(1)
          .and change(Evenement, :count)
          .by(0)
      end

      it 'ne persiste pas les métriques de la partie' do
        expect do
          FabriqueEvenement.new(parametres_invalide).call
        end.not_to have_enqueued_job(PersisteMetriquesPartieJob)
      end

      it "retourne une instance d'évènement" do
        expect(FabriqueEvenement.new(parametres_invalide).call.class).to eq Evenement
      end
    end
  end
end
