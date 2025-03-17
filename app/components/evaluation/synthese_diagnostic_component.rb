# frozen_string_literal: true

class Evaluation
  class SyntheseDiagnosticComponent < ViewComponent::Base
    def initialize(
      restitution_globale:,
      synthese_diagnostic:,
      mes_avec_redaction_de_notes:,
      niveau_cnef:,
      niveau_cefr:
    )
      @restitution_globale = restitution_globale
      @synthese_diagnostic = synthese_diagnostic
      @mes_avec_redaction_de_notes = mes_avec_redaction_de_notes
      @niveau_cnef = niveau_cnef
      @niveau_cefr = niveau_cefr
    end
  end
end
