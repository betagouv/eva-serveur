# frozen_string_literal: true

class BarreSegmenteeComponent < ViewComponent::Base
  def initialize(nombre_questions_reussies:, nombre_questions_echecs:,
                 nombre_questions_non_passees:, pourcentage_reussite:)
    @nombre_questions_reussies = nombre_questions_reussies
    @nombre_questions_echecs = nombre_questions_echecs
    @nombre_questions_non_passees = nombre_questions_non_passees
    @pourcentage_reussite = pourcentage_reussite
  end

  def nombre_questions_total
    @nombre_questions_reussies + @nombre_questions_echecs + @nombre_questions_non_passees
  end

  def pourcentage_questions(nombre_questions)
    return 0 if nombre_questions_total.zero?

    (nombre_questions.to_f / nombre_questions_total) * 100
  end

  def resultat
    if @pourcentage_reussite.nil?
      ''
    else
      "Score #{@pourcentage_reussite}% "
    end
  end
end
