# frozen_string_literal: true

require 'importeur_commentaires'

namespace :importe do
  desc 'Importe les commentaires Airtable'
  task :commentaires_airtable, [:fichier] => :environment do |_task, args|
    eva_bot = Compte.find_by email: Eva::EMAIL_SUPPORT
    CSV.foreach(args.fichier, headers: true, header_converters: :symbol) do |row|
      ImporteurCommentaires.importe row.to_hash, eva_bot
    end
  end
end
