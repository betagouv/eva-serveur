module Pdf
  class GenerationChannel < ApplicationCable::Channel
    def self.canal(token)
      "pdf_generation_#{token}"
    end

    def self.diffuse(token, payload)
      ActionCable.server.broadcast(canal(token), payload)
    end

    def subscribed
      compte_id = Pdf::GenerationToken.compte_id(params[:token])
      if compte_id && compte_id == current_compte&.id
        stream_from self.class.canal(params[:token])
      else
        reject
      end
    end
  end
end
