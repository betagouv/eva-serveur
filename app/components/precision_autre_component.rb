class PrecisionAutreComponent < BaseInputComponent
  def initialize(id:, questionnaire:, valeur: nil, erreur: nil)
    super(id: id, label: MiseEnAction.human_attribute_name(:precision_autre),
          hint: I18n.t("precision_autre.aide_#{questionnaire}"), required: true)
    @valeur = valeur
    @erreur = erreur
  end

  def has_errors?
    @erreur.present?
  end

  def classes_groupe
    classes = [ "fr-input-group", "precision-autre" ]
    classes << "fr-input-group--error" if has_errors?
    classes.join(" ")
  end
end
