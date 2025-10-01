require 'rails_helper'

describe 'nettoyage:recalcule_metriques' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  let!(:tri) { create :situation_tri, libelle: 'Situation Tri' }
  let(:evaluation) { create :evaluation }
  let!(:partie) do
    create :partie,
           evaluation: evaluation,
           situation: tri,
           metriques: { test: 'test' }
  end

  context 'appelé avec un nom de situation valide' do
    before do
      allow(logger).to receive :info
      allow(FabriqueRestitution).to receive(:instancie).with(partie).and_return restitution
      ENV['SITUATION'] = 'tri'
    end

    context 'persiste les restitutions terminées' do
      let(:restitution) { double(termine?: true) }

      it do
        expect(restitution).to receive(:persiste)
        subject.invoke
      end
    end

    context 'ignore les restitutions non terminees' do
      let(:restitution) { double(termine?: false) }

      it do
        expect(restitution).not_to receive(:persiste)
        subject.invoke
      end
    end
  end

  context 'appellé avec une situation inconnue' do
    it do
      ENV['SITUATION'] = 'inconnue'
      expect(logger).to receive(:error).with('Situation "inconnue" non trouvé')
      expect(logger).to receive(:info).exactly(0).times # ne doit pas recevoir le message de fin
      subject.invoke
    end
  end

  context 'appellé sans situation' do
    it do
      ENV['SITUATION'] = nil
      expect(logger).to receive(:error)
        .with("La variable d'environnement SITUATION est manquante")
      expect(logger).to receive(:info)
        .with('Usage : rake nettoyage:recalcule_metriques SITUATION=<nom_technique>')
      subject.invoke
    end
  end
end
