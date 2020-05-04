# frozen_string_literal: true

class Structure < ApplicationRecord
  validates :nom, :code_postal, presence: true
end
