# frozen_string_literal: true

require 'rails_helper'
require 'importeur_telephone'

describe ImporteurTelephone do
  let(:logger) { RakeLogger.logger }

  context 'le compte existe' do
    let!(:compte) { create :compte, email: 'conseiller@eva.fr', telephone: telephone }
    let(:ligne) { { mail: 'conseiller@eva.fr', telephone: '01-02-03-04-05' } }

    context 'pas de téléphone enregistré' do
      let(:telephone) { nil }

      it do
        expect(logger).to receive(:info)
          .with('Importe : conseiller@eva.fr,01-02-03-04-05')
        described_class.importe(ligne)
        expect(compte.reload.telephone).to eq '01-02-03-04-05'
      end
    end

    context 'avec un téléphone déjà enregistré' do
      let(:telephone) { '01 01 01 02 02' }

      it do
        expect(logger).to receive(:warn)
          .with('conseiller@eva.fr: téléphone 01 01 01 02 02 déjà présent; 01-02-03-04-05 ignoré')
        described_class.importe(ligne)
        expect(compte.reload.telephone).to eq '01 01 01 02 02'
      end
    end
  end

  context "le compte n'existe pas" do
    let(:ligne) { { mail: 'inconnu@eva.fr', telephone: '02 03 04 05 06' } }

    it do
      expect(logger).to receive(:warn)
        .with('Téléphone ignoré pour le compte inconnu : inconnu@eva.fr - 02 03 04 05 06')
      described_class.importe(ligne)
    end
  end
end
