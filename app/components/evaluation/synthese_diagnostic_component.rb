# frozen_string_literal: true

class Evaluation
  class SyntheseDiagnosticComponent < ViewComponent::Base
    def initialize(params = {})
      @restitution_globale = params[:restitution_globale]
      @synthese_diagnostic = params[:synthese_diagnostic]
      @mes_avec_redaction_de_notes = params[:mes_avec_redaction_de_notes]
      @niveau_cnef = params[:niveau_cnef]
      @niveau_cefr = params[:niveau_cefr]
      @completude_competences_de_base = params[:completude_competences_de_base]
    end
  end
end
