# frozen_string_literal: true

class QuestionClicDansTexte < Question
  QUESTION_TYPE = 'QuestionClicDansTexte'

  def as_json(_options = nil)
    base_json
  end

  private

  def base_json
    slice(:id, :nom_technique, :description, :illustration).tap do |json|
      json['type'] = 'clic-sur-mots'
      json['illustration'] = cdn_for(illustration)
      json['description'] = description
      json['reponse'] = { bonne_reponse: bonnes_reponses_json }
      json['texte_cliquable'] = texte_sur_illustration
    end
  end

  # Exemple de réponse: "bonnesReponses": ["mot1", "mot2"]
  def bonnes_reponses_json
    texte_sur_illustration.scan(/\[([^\]]+)\]\(#bonne-reponse\)/).flatten
  end
end
