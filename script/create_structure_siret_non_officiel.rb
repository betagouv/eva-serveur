#!/usr/bin/env ruby
# Script pour créer une structure avec un SIRET "non officiel" (non reconnu par l'API).
# Utile pour tester en local : rejoindre une structure existante en EVA avec un tel SIRET.
#
# Usage: bundle exec rails runner script/create_structure_siret_non_officiel.rb

SIRET_FAUX = "12345678910112"

structure = StructureLocale.new(
  siret: SIRET_FAUX,
  nom: "Structure test SIRET non officiel",
  code_postal: "75001",
  usage: "Eva: bénéficiaires",
  type_structure: StructureLocale::TYPE_NON_COMMUNIQUE
)

# L'API ne reconnaît pas ce SIRET → on force la sauvegarde sans valider le SIRET.
structure.save(validate: false)

# S'assurer que le statut reflète bien "non reconnu par l'API"
structure.update_column(:statut_siret, false) if structure.persisted?

puts "Structure créée : id=#{structure.id}, siret=#{structure.siret}, nom=#{structure.nom}"
puts "Tu peux tester l'embarquement en saisissant le SIRET #{SIRET_FAUX} sur la page recherche structure."
