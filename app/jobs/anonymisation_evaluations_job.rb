# frozen_string_literal: true

class AnonymisationEvaluationsJob < ApplicationJob
  queue_as :default

  def perform
    evaluations_de_plus_1_an.find_each do |evaluation|
      Anonymisation::Evaluation.new(evaluation).anonymise
    end
  end

  private

  def evaluations_de_plus_1_an
    Evaluation.where(anonymise_le: nil)
              .where(created_at: ...5.years.ago)
  end
end
