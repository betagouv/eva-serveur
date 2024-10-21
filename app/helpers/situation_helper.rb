# frozen_string_literal: true

module SituationHelper
  def situation_illustration(situation, couleur_bord: nil)
    return unless situation.illustration.attached?

    image_tag cdn_for(situation.illustration),
              style: couleur_bord.present? ? "border-color: #{couleur_bord};" : '',
              class: 'situation-illustration',
              alt: ''
  end
end
