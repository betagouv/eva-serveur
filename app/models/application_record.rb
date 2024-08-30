# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = 'created_at'

  def self.human_enum_name(enum_name, enum_value)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}"
    )
  end

  private

  def cdn_for(attachment)
    return unless attachment.attached?

    ApplicationController.helpers.cdn_for(attachment)
  end
end
