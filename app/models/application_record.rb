# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = 'created_at'

  def self.human_enum_name(enum_name, enum_value)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}"
    )
  end

  def self.ransackable_attributes(_auth_object = nil)
    attributes = column_names + _ransackers.keys + _ransack_aliases.keys
    attributes += attribute_aliases.keys if Ransack::SUPPORTS_ATTRIBUTE_ALIAS
    attributes.uniq
  end

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end

  private

  def cdn_for(attachment)
    return unless attachment.attached?

    ApplicationController.helpers.cdn_for(attachment)
  end

  def svg_attachment_base64(attachment)
    ApplicationController.helpers.svg_attachment_base64(attachment)
  end
end
