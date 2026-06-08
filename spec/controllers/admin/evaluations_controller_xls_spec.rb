require "rails_helper"

RSpec.describe Admin::EvaluationsController, type: :controller do
  describe "mapping XLS Eva Pro" do
    let(:evaluation) { build_stubbed(:evaluation, id: 123) }

    before do
      allow(controller).to receive_messages(
        current_compte: instance_double(Compte, utilisateur_entreprise?: true),
        syntheses_evapro_par_evaluation_id: {
          evaluation.id => {
            pourcentage_risque: 25,
            score_cout: "fort",
            synthese_impact: {
              "performance_collective" => "faible",
              "agilite_organisationnelle" => "moyen",
              "securite_qualite" => "fort",
              "mobilite_professionnelle" => "tres_fort",
              "score_cout" => "fort"
            }.with_indifferent_access
          }
        }
      )
    end

    it "garde le taux de risque en pourcentage" do
      expect(controller.send(:taux_risque_pour_xls, evaluation)).to eq("25 %")
    end

    it "retourne la recommandation pour le bilan de situation" do
      expect(controller.send(:recommandation_risque_pour_xls, evaluation)).to eq("Anticiper")
    end

    it "retourne les lettres d'impact A/B/C/D" do
      expect(controller.send(:impact_evapro_pour_xls, evaluation,
        :performance_collective)).to eq("A")
      expect(controller.send(:impact_evapro_pour_xls, evaluation,
        :agilite_organisationnelle)).to eq("B")
      expect(controller.send(:impact_evapro_pour_xls, evaluation, :securite_qualite)).to eq("C")
      expect(controller.send(:impact_evapro_pour_xls, evaluation,
        :mobilite_professionnelle)).to eq("D")
    end

    it "retourne le coût formaté depuis les traductions" do
      expect(controller.send(:score_cout_pour_xls, evaluation)).to eq("3 à 4%")
    end
  end
end
