# frozen_string_literal: true

namespace :nettoyage do
  desc 'Ajoute les événements terminés'
  task :ajoute_evenements_termines, :environment do
    Partie.find_each do |partie|
      evenements = Evenement.where(partie: partie)
      next if evenements.where(nom: 'finSituation').exists?

      restitution = FabriqueRestitution.instancie partie.id
      next unless restitution.termine?

      dernier_evenement = evenements.order(:date).last
      Evenement.create! partie: partie, nom: 'finSituation', date: dernier_evenement.date
    end
  end

  desc 'Supprime les événements après la fin'
  task :supprime_evenements_apres_la_fin, :environment do
    Partie.find_each do |partie|
      evenements = Evenement.where(partie: partie).order(:date)
      evenements_jusqua_fin = evenements.take_while do |evenement|
        evenement.nom != 'finSituation'
      end

      evenements_apres_fin = evenements - evenements_jusqua_fin
      evenements_apres_fin = evenements_apres_fin.drop(1)
      Evenement.where(id: evenements_apres_fin.collect(&:id)).destroy_all
    end
  end
end
