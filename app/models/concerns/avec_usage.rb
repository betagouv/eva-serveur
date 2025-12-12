module AvecUsage
  extend ActiveSupport::Concern

  USAGE_BENEFICIAIRES = "Eva: bénéficiaires".freeze
  USAGE_ENTREPRISES = "Eva: entreprises".freeze
  USAGE = [ USAGE_BENEFICIAIRES, USAGE_ENTREPRISES ].freeze

  included do
    validates :usage, inclusion: { in: USAGE }, allow_blank: true
  end

  def eva_entreprises?
    usage == "Eva: entreprises"
  end

  def eva_beneficiaires?
    usage == "Eva: bénéficiaires"
  end
end
