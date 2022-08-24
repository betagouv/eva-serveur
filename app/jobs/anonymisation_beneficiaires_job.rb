# frozen_string_literal: true

class AnonymisationBeneficiairesJob < ApplicationJob
  queue_as :default

  def perform
    beneficiaire_avec_evaluations_de_plus_1_an.find_each do |beneficiaire|
      Anonymisation::Beneficiaire.new(beneficiaire).anonymise
      beneficiaire.evaluations.each do |evaluation|
        Anonymisation::Evaluation.new(evaluation).anonymise
      end
    end
  end

  private

  def beneficiaire_avec_evaluations_de_plus_1_an
    Beneficiaire
      .select('beneficiaires.*, MAX(evaluations.created_at) AS derniere_evaluation_date')
      .joins(:evaluations).group('beneficiaires.id').having(
        'MAX(evaluations.created_at) < ?', 1.year.ago
      )
  end
end
