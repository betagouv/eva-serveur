# frozen_string_literal: true

class AnonymisationBeneficiairesJob < ApplicationJob
  queue_as :default

  ANNEES_CONSERVEES = 5

  def perform
    beneficiaires_a_annonymiser.find_each do |beneficiaire|
      nom_genere = FFaker::NameFR.name
      Anonymisation::Beneficiaire.new(beneficiaire).anonymise(nom_genere)
      beneficiaire.evaluations.each do |evaluation|
        Anonymisation::Evaluation.new(evaluation).anonymise(nom_genere)
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
