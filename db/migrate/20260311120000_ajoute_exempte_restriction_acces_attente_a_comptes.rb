# frozen_string_literal: true

# Champ d'exemption pour la restriction d'accès des comptes en attente (EVA-817).
# Ce champ pourra peut-être être supprimé plus tard, une fois que tous les comptes
# alors exemptés auront été traités (approbation ou clôture).
# Ticket : https://captive-team.atlassian.net/browse/EVA-817
class AjouteExempteRestrictionAccesAttenteAComptes < ActiveRecord::Migration[7.2]
  def up
    add_column :comptes, :exempte_restriction_acces_attente, :boolean, default: false, null: false

    Compte.reset_column_information
    Compte.where(statut_validation: 0).update_all(exempte_restriction_acces_attente: true)
  end

  def down
    remove_column :comptes, :exempte_restriction_acces_attente
  end
end
