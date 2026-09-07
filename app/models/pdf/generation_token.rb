module Pdf
  class GenerationToken
    DUREE_VALIDITE = 10.minutes
    PURPOSE = :pdf_generation

    def self.genere(compte_id)
      verifier.generate({ compte_id: compte_id }, expires_in: DUREE_VALIDITE, purpose: PURPOSE)
    end

    def self.compte_id(token)
      verifier.verify(token, purpose: PURPOSE)[:compte_id]
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    def self.verifier
      Rails.application.message_verifier(:pdf_generation)
    end
  end
end
