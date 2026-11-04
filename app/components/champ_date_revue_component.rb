class ChampDateRevueComponent < BaseInputComponent
  def initialize(id:, valeur: nil)
    super(id: id, label: MiseEnAction.human_attribute_name(:date_revue),
          hint: I18n.t("date_revue_mise_en_action.format_attendu"), required: true)
    @valeur = valeur
  end

  def demain
    Date.current.tomorrow.iso8601
  end
end
