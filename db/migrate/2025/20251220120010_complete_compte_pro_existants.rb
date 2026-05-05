class CompleteCompteProExistants < ActiveRecord::Migration[7.2]
  def up
    Compte.where.not(siret_pro_connect: nil, structure: nil).update_all(etape_inscription: 'complet')
  end

  def down
    Compte.where.not(siret_pro_connect: nil, structure: nil).update_all(etape_inscription: 'preinscription')
  end
end
