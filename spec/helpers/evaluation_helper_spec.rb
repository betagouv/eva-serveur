# frozen_string_literal: true

require 'rails_helper'

describe EvaluationHelper do
  describe '#niveau_bas?' do
    let(:profil1) { Competence::PROFILS_BAS.first }
    let(:profil_autre) { :profil_autre }

    it 'Retourne true si le profil renseigné est un niveau bas' do
      expect(niveau_bas?(:profil1)).to be true
    end

    it "Retourne false si le profil renseigné n'est pas un niveau bas" do
      expect(niveau_bas?(:profil_autre)).to be false
    end
  end

  describe "#badge_positionnement" do
    let(:campagne) { instance_double(Campagne) }
    let(:evaluation) { instance_double(Evaluation, campagne: campagne) }

    before do
      allow(helper).to receive(:construit_badge).and_return("<fr-badge />".html_safe)
    end

    context "quand la campagne a un positionnement pour la compétence" do
      before do
        allow(campagne).to receive(:avec_positionnement?).with(:litteratie).and_return(true)
        allow(evaluation).to receive(:positionnement_niveau_litteratie).and_return("profil1")
        allow(helper).to receive(:traduit_niveau)
          .with(evaluation, :positionnement_niveau_litteratie)
          .and_return("Profil 1")
      end

      it "construit un badge avec le contenu traduit et le niveau" do
        helper.badge_positionnement(evaluation, :litteratie)

        expect(helper).to have_received(:construit_badge).with("Profil 1", "profil1")
      end
    end

    context "quand la campagne n’a pas de positionnement pour la compétence" do
      before do
        allow(campagne).to receive(:avec_positionnement?).with(:numeratie).and_return(false)
      end

      it "construit un badge avec 'Non testé' et niveau nil" do
        helper.badge_positionnement(evaluation, :numeratie)

        expect(helper).to have_received(:construit_badge).with("Non testé", nil)
      end
    end
  end
end
