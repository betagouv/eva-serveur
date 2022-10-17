class RemplaceCentreActionSocialparServiceInsertionCollectivite < ActiveRecord::Migration[6.1]
  AVANT = 'centre_action_social'
  APRES = 'service_insertion_collectivite'

  class Structure < ApplicationRecord; end

  def up
    Structure.where(type_structure: AVANT)
             .update_all(type_structure: APRES)
  end

  def down
    Structure.where(type_structure: APRES)
             .update_all(type_structure: AVANT)
  end
end
