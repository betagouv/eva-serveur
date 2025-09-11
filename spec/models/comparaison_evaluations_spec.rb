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
end
