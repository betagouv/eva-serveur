# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComparaisonEvaluations, type: :model do
  describe "#valid?" do
    it "ne doit pas avoir plus de 2 évaluations pour la compétence Numératie" do
      evaluations = create_list(:evaluation, 3, :numeratie)

      expect(described_class.new(evaluations).valid?).to be false
    end

    it "ne doit pas avoir plus de 2 évaluations pour la compétence Littératie" do
      evaluations = create_list(:evaluation, 3, :litteratie)

      expect(described_class.new(evaluations).valid?).to be false
    end
  end

  describe "#evaluations_numeratie" do
    it "Les évaluations pour la numératie, trier du plus vieux au plus récent" do
      evaluations = [
        create(:evaluation, :numeratie, debutee_le: 3.days.ago),
        create(:evaluation, :numeratie, debutee_le: 5.days.ago),
        create(:evaluation, :litteratie, debutee_le: 1.day.ago)
      ]

      expect(described_class.new(evaluations).evaluations_numeratie).to eq [
        evaluations[1],
        evaluations[0]
      ]
    end
  end

  describe "#evaluations_litteratie" do
    it "Les évaluations pour la littératie, trier du plus vieux au plus récent" do
      evaluations = [
        create(:evaluation, :litteratie, debutee_le: 3.days.ago),
        create(:evaluation, :litteratie, debutee_le: 5.days.ago),
        create(:evaluation, :numeratie, debutee_le: 1.day.ago)
      ]

      expect(described_class.new(evaluations).evaluations_litteratie).to eq [
        evaluations[1],
        evaluations[0]
      ]
    end
  end
end
