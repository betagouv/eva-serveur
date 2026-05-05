class ActualiseEmailSupport < ActiveRecord::Migration[7.2]
  def up
    email_support = Compte.find_by(email: 'support@eva.beta.gouv.fr')
    email_support&.update_columns(email: 'eva@anlci.gouv.fr')
  end

  def down
    email_support = Compte.find_by(email: 'eva@anlci.gouv.fr')
    email_support&.update_columns(email: 'support@eva.beta.gouv.fr')
  end
end
