require_relative "../../decorators/evenement_livraison"

module Restitution
  class Livraison < AvecEntrainement
    METRIQUES = {
      "nombre_reponses_ccf" => {
        "type" => :nombre,
        "metacompetence" => "ccf",
        "instance" => Illettrisme::NombreReponses.new
      },
      "nombre_reponses_syntaxe_orthographe" => {
        "type" => :nombre,
        "metacompetence" => "syntaxe-orthographe",
        "instance" => Illettrisme::NombreReponses.new
      },
      "nombre_bonnes_reponses_numeratie" => {
        "type" => :nombre,
        "metacompetence" => "numeratie",
        "instance" => Illettrisme::NombreBonnesReponses.new
      },
      "nombre_bonnes_reponses_ccf" => {
        "type" => :nombre,
        "metacompetence" => "ccf",
        "instance" => Illettrisme::NombreBonnesReponses.new
      },
      "nombre_bonnes_reponses_syntaxe_orthographe" => {
        "type" => :nombre,
        "metacompetence" => "syntaxe-orthographe",
        "instance" => Illettrisme::NombreBonnesReponses.new
      },
      "temps_moyen_bonnes_reponses_numeratie" => {
        "type" => :nombre,
        "metacompetence" => "numeratie",
        "instance" => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      "temps_moyen_bonnes_reponses_ccf" => {
        "type" => :nombre,
        "metacompetence" => "ccf",
        "instance" => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      "temps_moyen_bonnes_reponses_syntaxe_orthographe" => {
        "type" => :nombre,
        "metacompetence" => "syntaxe-orthographe",
        "instance" => Metriques::Moyenne.new(Illettrisme::TempsBonnesReponses.new)
      },
      "score_numeratie" => {
        "type" => :nombre,
        "metacompetence" => "numeratie",
        "instance" => Illettrisme::ScoreMetacompetence.new
      },
      "score_ccf" => {
        "type" => :nombre,
        "metacompetence" => "ccf",
        "instance" => Illettrisme::ScoreMetacompetence.new
      },
      "score_syntaxe_orthographe" => {
        "type" => :nombre,
        "metacompetence" => "syntaxe-orthographe",
        "instance" => Illettrisme::ScoreMetacompetence.new
      }
    }.freeze

    delegate :questions_et_reponses, :questions_redaction, to: :questions_reponses

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementLivraison.new e }
      super
    end

    METRIQUES.each_key do |metrique|
      define_method metrique do
        METRIQUES[metrique]["instance"]
          .calcule(evenements_situation, METRIQUES[metrique]["metacompetence"])
      end
    end

    def questions_reponses
      @questions_reponses ||= QuestionsReponses.new(evenements_situation)
    end

    def efficience
      nil
    end
  end
end
