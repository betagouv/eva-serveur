class DefiniLeCodeDesCampagnesExistantesEnMajuscule < ActiveRecord::Migration[6.1]
  def up
    Campagne.find_each do |campagne|
      campagne.update!(code: campagne.code.upcase)
    end
  end
end
