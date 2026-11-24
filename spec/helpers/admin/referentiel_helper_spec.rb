require "rails_helper"

describe Admin::ReferentielHelper, type: :helper do
  it "propose de voir, modifier et supprimer par les routes du modèle" do
    actions = helper.actions_referentiel(QuestionSaisie)

    expect(actions.pluck(:url))
      .to eq %i[admin_question_saisie_path edit_admin_question_saisie_path
admin_question_saisie_path]
    expect(actions.pluck(:type)).to eq %i[read edit destroy]
  end

  it "insère les actions propres au référentiel avant la suppression" do
    exporter = { label: "Exporter", type: :read, url: :export_admin_questionnaire_path }

    expect(helper.actions_referentiel(Questionnaire, exporter).pluck(:label))
      .to eq [ I18n.t("active_admin.view"), I18n.t("active_admin.edit"), "Exporter",
               I18n.t("active_admin.delete") ]
  end
end
