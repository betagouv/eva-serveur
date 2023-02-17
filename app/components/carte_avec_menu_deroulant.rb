# frozen_string_literal: true

class CarteAvecMenuDeroulant < ViewComponent::Base
  include EvaluationHelper

  def initialize(ressource, question, reponses, menu_affiche: true, priorite: nil)
    @ressource = ressource
    @question = question
    @reponses = reponses
    @menu_affiche = menu_affiche
    @priorite = priorite
  end
end
