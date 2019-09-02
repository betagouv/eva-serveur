# frozen_string_literal: true

class Choix < ApplicationRecord
  validates :intitule, :type_choix, presence: true
  enum type_choix: %i[bon mauvais abstention]

  acts_as_list scope: :question_id

  scope :de_type, ->(type) { find_by(type_choix: type).id.to_s }

  def as_json(_options = nil)
    slice(:id, :intitule, :type_choix)
  end
end
