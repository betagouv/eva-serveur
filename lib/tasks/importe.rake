# frozen_string_literal: true

require 'importeur_commentaires'
require 'importeur_telephone'

namespace :importe do
  desc 'Importe les commentaires Airtable'
  task commentaires_airtable: :environment do
    eva_bot = Compte.find_by email: Eva::EMAIL_SUPPORT
    if eva_bot.blank?
      RakeLogger.logger.error("eva Bot n'existe pas")
      exit
    end
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      ImporteurCommentaires.importe row.to_hash, eva_bot
    end
  end

  desc 'Importe les numéros de téléphone des conseillers connus'
  task telephones: :environment do
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      ImporteurTelephone.importe row.to_hash
    end
  end
end
