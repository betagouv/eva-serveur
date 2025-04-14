# frozen_string_literal: true

class BadgeAcquisitionComponent < ViewComponent::Base
  STATUS = %i[acquis non_acquis non_evalue].freeze
  COLORS_CLASSES = {
    acquis: [ "fr-badge--green-emeraude" ],
    non_acquis: [ "fr-badge--orange-terre-battue" ],
    non_evalue: [ "fr-badge--grey" ]
  }.freeze

  ICONES = {
    acquis: "checkbox-circle-fill",
    non_acquis: "close-circle-fill",
    non_evalue: "indeterminate-circle-fill"
  }.freeze

  def initialize(status:, classes: [])
    @status = status
    @classes = classes + COLORS_CLASSES[@status]
    @text = I18n.t(".badge_acquisition.#{status}")

    validation
  end

  private

  def validation
    return if STATUS.include? @status.to_sym

    valeurs = STATUS.join(", ")
    raise "Le status #{@status} est invalide pour BadgeProfilComponent. Valeurs possible : #{valeurs}" # rubocop:disable Layout/LineLength
  end

  def icone
    ICONES[@status]
  end
end
