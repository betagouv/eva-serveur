# frozen_string_literal: true

require 'importeur_commentaires'

namespace :importe do
  desc 'Importe les commentaires Airtable'
  task commentaires_airtable: :environment do
    eva_bot = Compte.find_by email: Eva::EMAIL_SUPPORT
    CSV.parse($stdin, headers: true, header_converters: :symbol).each do |row|
      ImporteurCommentaires.importe row.to_hash, eva_bot
    end
  end
end
