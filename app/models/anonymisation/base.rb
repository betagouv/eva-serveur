module Anonymisation
  class Base
    def initialize(model)
      @model = model
    end

    def anonymise
      yield(@model)
      @model.anonymise_le = Time.current
      @model.save!
    end
  end
end
