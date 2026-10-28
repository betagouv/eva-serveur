require "rails_helper"

describe Qcm, type: :component do
  subject(:component) do
    described_class.new(evaluation, MiseEnAction::Questionnaire.new(:remediation))
  end

  let(:evaluation) { build(:evaluation) }

  it "désactive le bouton de validation tant qu'aucune réponse n'est choisie" do
    render_inline(component)

    expect(page).to have_button(I18n.t("qcm.action_valider"), disabled: true)
  end
end
