# frozen_string_literal: true

class QuestionClicDansTexte < Question
  QUESTION_TYPE = 'QuestionClicDansTexte'

  enum :metacompetence, Metacompetence::METACOMPETENCES

  def as_json(_options = nil)
    json = base_json
    json.merge!(json_audio_fields, additional_json_fields)
  end

  private

  def base_json
    slice(:id, :nom_technique, :description, :illustration,
          :demarrage_audio_modalite_reponse, :score, :metacompetence).tap do |json|
      json['type'] = 'clic-sur-mots'
      json['illustration'] = illustration_url
      json['description'] = description
      json['reponse'] = { bonne_reponse: bonnes_reponses_json }
      json['texte_cliquable'] = texte_sur_illustration
    end
  end

  def additional_json_fields
    { 'intitule' => transcription_intitule&.ecrit,
      'modalite_reponse' => transcription_modalite_reponse&.ecrit }
  end

  # Exemple de réponse: "bonnesReponses": ["mot1", "mot2"]
  def bonnes_reponses_json
    texte_sur_illustration.scan(/\[([^\]]+)\]\(#bonne-reponse\)/).flatten
  end
end
