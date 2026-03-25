# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire do
  describe "#enregistre_mise_en_action" do
    let(:date_du_jour) { Time.zone.local(2023, 1, 1, 12, 0, 0) }

    context "lorsque la mise en action existe déjà" do
      let(:ancienne_date) { Time.zone.local(2022, 1, 1, 10, 0, 0) }
      let!(:evaluation) do
        create :evaluation, :avec_mise_en_action, repondue_le: ancienne_date
      end

      context "avec une remediation" do
        it "met à jour la réponse, la date, et efface la remédiation" do
          evaluation.mise_en_action.update(effectuee: true, remediation: :formation_metier)

          Timecop.freeze(date_du_jour) do
            described_class.new(evaluation).enregistre_mise_en_action(false)
          end

          evaluation.reload
          expect(evaluation.mise_en_action.effectuee).to be(false)
          expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
          expect(evaluation.mise_en_action.remediation).to be_nil
        end
      end

      context "avec une difficulté" do
        it "met à jour la réponse, la date, et efface la difficulté" do
          evaluation.mise_en_action.update(effectuee: false, difficulte: :freins_peripheriques)

          Timecop.freeze(date_du_jour) do
            described_class.new(evaluation).enregistre_mise_en_action(true)
          end

          evaluation.reload
          expect(evaluation.mise_en_action.effectuee).to be(true)
          expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
          expect(evaluation.mise_en_action.difficulte).to be_nil
        end
      end
    end

    context "quand il n'y a pas de mise en action associée" do
      let!(:evaluation) { create :evaluation }

      it "crée et enregistre une réponse true" do
        Timecop.freeze(date_du_jour) do
          described_class.new(evaluation).enregistre_mise_en_action(true)
        end

        expect(evaluation.mise_en_action.effectuee).to be(true)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end

      it "crée et enregistre une réponse false" do
        Timecop.freeze(date_du_jour) do
          described_class.new(evaluation).enregistre_mise_en_action(false)
        end

        expect(evaluation.mise_en_action.effectuee).to be(false)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end
    end
  end
end
