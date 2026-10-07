class MetAJourLesSecteursDActivite < ActiveRecord::Migration[8.0]
  # [nom_technique, intitule, score des risques], dans l'ordre d'affichage.
  SECTEURS = [
    [ "Q1IC03R01", "Agriculture et pêche", 2 ],
    [ "Q1IC03R02", "Agro-alimentaire", 2 ],
    [ "Q1IC03R03", "Aide à domicile", 2 ],
    [ "Q1IC03R04", "Animation, sport, loisirs et spectacles", 1 ],
    [ "Q1IC03R05", "BTP", 2 ],
    [ "Q1IC03R07", "Commerce", 1 ],
    [ "Q1IC03R08", "Entretien, maintenance, services techniques", 1 ],
    [ "Q1IC03R09", "Espaces-verts", 1 ],
    [ "Q1IC03R19", "Ferroviaire, manutention ferroviaire", 1 ],
    [ "Q1IC03R20", "Fonction Publique d'État (FPE)", 1 ],
    [ "Q1IC03R10", "Fonction Publique Hospitalière (FPH)", 1 ],
    [ "Q1IC03R06", "Fonction Publique Territoriale (FPT)", 1 ],
    [ "Q1IC03R11", "Hôtellerie - restauration - café", 1 ],
    [ "Q1IC03R12",
      "Industrie (métallurgie, chimie, bois / papier, pharmacie, textile, automobile, etc.)", 2 ],
    [ "Q1IC03R21", "Logistique", 1 ],
    [ "Q1IC03R22", "Négoce des matériaux de construction (NMC)", 1 ],
    [ "Q1IC03R13", "Propreté - entretien", 2 ],
    [ "Q1IC03R14", "Sanitaire social et médico-social", 1 ],
    [ "Q1IC03R15", "Sécurité", 1 ],
    [ "Q1IC03R16", "Transports urbains, Transport de marchandises", 1 ],
    [ "Q1IC03R17", "Autre", 1 ],
    [ "Q1IC03R18", "Je ne sais pas", 2 ]
  ].freeze

  def up
    question = Question.find_by(nom_technique: "Q1IC03")
    return unless question

    SECTEURS.each.with_index(1) do |(nom_technique, intitule, score), position|
      choix = Choix.find_or_initialize_by(question_id: question.id, nom_technique: nom_technique)
      choix.type_choix ||= :bon
      choix.update!(intitule: intitule, score: { "risques" => score })
      choix.update_column(:position, position)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
