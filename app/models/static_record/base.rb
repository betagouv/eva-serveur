# frozen_string_literal: true

module StaticRecord
  ##
  # Cette classe est une classe générique qui s'inspire de ActiveRecord::Base
  # pour permettre de charger des données depuis des fichiers YAML.
  # Les fichiers YAML doivent être placés dans le dossier db/data/
  class Base
    class << self
      # Chemin vers les données à charger.
      # Exemple d'usage :
      # class MyModel < StaticRecord::Base
      #  self.chemin_data = 'my_model/*.yml'
      # end
      attr_accessor :chemin_data

      # Charge l'ensemble des données depuis les fichiers YAML.
      # Exemple d'usage : MyModel.all
      def all
        @data = charge_data.map do |data|
          new(data)
        end
      end

      # Retourne les données qui correspondent aux conditions passées en paramètre.
      # Exemple d'usage : MyModel.where(nom: 'John Doe')
      def where(conditions = {})
        all.select do |record|
          conditions.all? { |key, value| record.send(key) == value }
        end
      end

      # Retourne la première donnée qui correspond aux conditions passées en paramètre.
      # Exemple d'usage : MyModel.find_by(nom: 'John Doe')
      def find_by(conditions = {})
        all.find do |record|
          conditions.all? { |key, value| record.send(key) == value }
        end
      end

      private

      def charge_data
        Rails.root.glob("db/data/#{chemin_data}").flat_map do |file|
          YAML.load_file(file)
        end
      end
    end
  end
end
