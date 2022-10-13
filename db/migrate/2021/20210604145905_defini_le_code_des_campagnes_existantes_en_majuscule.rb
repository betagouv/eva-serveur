class DefiniLeCodeDesCampagnesExistantesEnMajuscule < ActiveRecord::Migration[6.1]
  class Campagne < ApplicationRecord; end

  def up
    Campagne.find_each do |campagne|
      unless campagne.update(code: campagne.code.upcase)
        raise "erreur, #{campagne.code.upcase} : #{campagne.errors.full_messages}"
      end
    end
  end
end
