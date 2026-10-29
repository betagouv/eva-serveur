module AvecUsage
  extend ActiveSupport::Concern

  USAGE_EVA = "eva".freeze
  USAGE_EVAPRO = "evapro".freeze
  USAGE = [ USAGE_EVA, USAGE_EVAPRO ].freeze

  included do
    validates :usage, inclusion: { in: USAGE }, allow_blank: true
  end

  def evapro?
    usage == USAGE_EVAPRO
  end
end
