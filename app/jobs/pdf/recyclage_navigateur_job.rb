module Pdf
  class RecyclageNavigateurJob < ApplicationJob
    queue_as :pdf

    def perform
      Pdf::Navigateur.redemarre!
    end
  end
end
