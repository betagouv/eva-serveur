# frozen_string_literal: true

class AnonymisationBeneficiairesJob < ApplicationJob
  queue_as :default

  ANNEES_CONSERVEES = 5

  def perform
    beneficiaires_a_annonymiser.find_each do |beneficiaire|
      Anonymisation::Beneficiaire.new(beneficiaire).anonymise
      beneficiaire.evaluations.each do |evaluation|
        Anonymisation::Evaluation.new(evaluation).anonymise
      end
    end
  end

  private

  def beneficiaires_a_annonymiser
    Beneficiaire
      .select('beneficiaires.*')
      .where(anonymise_le: nil)
      .joins(:evaluations).group('beneficiaires.id').having(
        'MAX(evaluations.created_at) < ?', ANNEES_CONSERVEES.year.ago
      )
  end
end
