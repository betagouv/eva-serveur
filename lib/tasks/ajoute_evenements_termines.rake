# frozen_string_literal: true

desc 'Ajoute les événements terminés'
task :ajoute_evenements_termines, :environment do
  Partie.find_each do |partie|
    dernier_evenement = Evenement.where(partie: partie).order(:date).last
    next if dernier_evenement&.nom == 'finSituation'

    restitution = FabriqueRestitution.instancie partie.id
    next unless restitution.termine?

    Evenement.create! partie: partie, nom: 'finSituation', date: dernier_evenement.date
  end
end
