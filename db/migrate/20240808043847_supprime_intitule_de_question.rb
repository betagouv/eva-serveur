class SupprimeIntituleDeQuestion < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end

  def up
    remove_column :questions, :intitule, :string
  end

  def down
    add_column :questions, :intitule, :string
    Question.find_each do |question|
      if question.transcription_intitule.present?
        question.update(intitule: question.transcription_intitule&.ecrit)
      end
    end
  end
end
