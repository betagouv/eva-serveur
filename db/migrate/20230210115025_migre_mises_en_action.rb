class MigreMisesEnAction < ActiveRecord::Migration[7.0]
  class Evaluation < ApplicationRecord; end

  def change
    Evaluation.where.not(mise_en_action_effectuee: nil).find_each do |evaluation|
      next if MiseEnAction.exists?(evaluation_id: evaluation.id)

      MiseEnAction.create(effectuee: evaluation.mise_en_action_effectuee, evaluation_id: evaluation.id, repondue_le: evaluation.mise_en_action_le)
    end
  end
end
