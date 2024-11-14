# frozen_string_literal: true

class QuestionClicDansTexte < Question
  validates :texte_sur_illustration, presence: true

  def as_json(_options = nil)
    base_json
  end

  private

  def base_json
    slice(:id, :nom_technique, :description, :texte_sur_illustration,
          :illustration).tap do |json|
      json['type'] = 'clic-dans-texte'
      json['illustration'] = cdn_for(illustration)
      json['description'] = description
      json['bonnesReponses'] = bonnes_reponses_json
    end
  end

  # Exemple de réponse: "bonnesReponses": ["mot1", "mot2"]
  def bonnes_reponses_json
    texte_sur_illustration.scan(/\[([^\]]+)\]\(#bonne-reponse\)/).flatten
  end
end
