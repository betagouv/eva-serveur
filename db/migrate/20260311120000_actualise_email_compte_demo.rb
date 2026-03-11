class ActualiseEmailCompteDemo < ActiveRecord::Migration[7.2]
  def up
    compte_demo = Compte.find_by(email: 'demo@eva.beta.gouv.fr')
    compte_demo&.update_columns(email: 'demo@eva.anlci.gouv.fr', confirmed_at: Time.current)
  end

  def down
    compte_demo = Compte.find_by(email: 'demo@eva.anlci.gouv.fr')
    compte_demo&.update_columns(email: 'demo@eva.beta.gouv.fr', confirmed_at: Time.current)
  end
end
