module ActualiteHelper
  CLASSES_BADGE_CATEGORIES = {
    "assistance" => "fr-badge--pink-macaron",
    "blog" => "fr-badge--yellow-tournesol",
    "evolution" => "fr-badge--green-emeraude"
  }.freeze

  def classe_badge_categorie_actualite(categorie)
    CLASSES_BADGE_CATEGORIES[categorie.to_s]
  end
end
