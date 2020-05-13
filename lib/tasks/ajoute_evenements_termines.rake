# frozen_string_literal: true

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
