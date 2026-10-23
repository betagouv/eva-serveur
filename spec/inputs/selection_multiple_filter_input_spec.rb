require "rails_helper"

describe SelectionMultipleFilterInput, type: :input do
  let(:template) do
    ActionView::Base.new(
      ActionView::LookupContext.new([]),
      {},
      ActionController::Base.new
    )
  end
  let(:statuts_choisis) { [] }
  let(:recherche) { EvaluationEva.ransack(statut_suivi_in: statuts_choisis) }
  let(:builder) { ActiveAdmin::Filters::FormBuilder.new(:q, recherche, template, {}) }
  let(:options) do
    {
      label: "Suivi",
      collection: [ [ "À renseigner", "a_renseigner" ], [ "Reporté", "reporte" ],
                    [ "Suite engagée", "suite_engagee" ] ],
      cle_resume: "statut_suivi.resume_filtre"
    }
  end
  let(:input) { described_class.new(builder, template, recherche, :q, :statut_suivi, options) }

  describe "#to_html" do
    subject(:html) { Capybara.string(input.to_html) }

    it "affiche une case par choix dans une liste dépliable" do
      expect(html).to have_css("details.selection-multiple input[type='checkbox']",
                               count: 3, visible: :all)
      expect(html).to have_css("input[name='q[statut_suivi_in][]'][value='reporte']", visible: :all)
    end

    it "affiche un résumé vide quand rien n'est coché" do
      expect(html.find("summary").text.strip).to eq ""
    end

    context "quand un seul choix est coché" do
      let(:statuts_choisis) { [ "reporte" ] }

      it "résume avec le libellé du choix" do
        expect(html.find("summary").text.strip).to eq "Reporté"
        expect(html).to have_css("input[value='reporte'][checked]", visible: :all)
      end
    end

    context "quand plusieurs choix sont cochés" do
      let(:statuts_choisis) { %w[a_renseigner reporte] }

      it "résume avec le nombre de choix" do
        expect(html.find("summary").text.strip).to eq "2 statuts"
      end
    end
  end
end
