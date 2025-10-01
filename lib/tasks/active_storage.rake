namespace :active_storage do
  desc "Supprime complètement tous les fichiers attachés des modèles (destroy)"
  task destroy_attachments: :environment do
    unless Rails.env.development?
      puts "❌ La tache doit être exécuté uniquement en environnement de développement"
      return
    end
    if ENV["AWS_ACCESS_KEY_ID"]
      puts "❌ Supprimer les variables d'environnement de AWS"
      return
    end

    Rails.application.eager_load! # Charge tous les modèles

    models = ActiveRecord::Base.descendants

    models.each do |model|
      next unless model < ApplicationRecord # Évite les classes abstraites

      model.reflect_on_all_attachments.map(&:name).each do |association|
        puts "- Suppression complète des fichiers pour #{model.name}##{association.name}"
        model.find_each do |record|
          attachment = record.send(association.name)
          attachment.attachment&.destroy if attachment.attached?
        end
      end
    end

    puts "✅ Tous les fichiers attachés ont été supprimés de la base et du stockage."
  end
end
