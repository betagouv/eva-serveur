# frozen_string_literal: true

module Anonymisation
  class Base
    def initialize(model)
      @model = model
    end

    def anonymise(_nouveau_nom = nil)
      yield(@model)
      @model.anonymise_le = Time.current
      @model.save!
    end
  end
end
