# frozen_string_literal: true

module SituationHelper
  def situation_illustration(situation)
    return unless situation.illustration.attached?

    image_tag(cdn_for(situation.illustration), height: '64px')
  end
end
