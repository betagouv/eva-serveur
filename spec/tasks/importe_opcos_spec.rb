require 'rails_helper'
require 'roo'

describe 'importe:opcos' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }
  let(:chemin_fichier) { Rails.root.join('config', 'data', 'tableau-correspondance-opco.xlsx') }

  before do
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  context 'quand le fichier Excel existe' do
    let(:sheet) do
      instance_double(Roo::Excelx::Sheet,
                      last_row: 6,
                      row: nil)
    end
    let(:xlsx) do
      instance_double(Roo::Excelx,
                      sheet: sheet)
    end

    before do
      allow(File).to receive(:exist?).with(chemin_fichier).and_return(true)
      allow(Roo::Spreadsheet).to receive(:open).with(chemin_fichier.to_s).and_return(xlsx)
    end

    context 'avec des données valides' do
      before do
        # Simule les lignes du fichier Excel
        # Ligne 1: headers (ignorée)
        # Ligne 2: IDCC=3, Opco="OPCO Mobilité"
        # Ligne 3: IDCC=16, Opco="OPCO Mobilité"
        # Ligne 4: IDCC=18, Opco="OPCO 2i"
        # Ligne 5: IDCC=na, Opco="OPCO Test" (doit être ignoré)
        # Ligne 6: IDCC=N.A, Opco="OPCO Test 2" (doit être ignoré)
        allow(sheet).to receive(:last_row).and_return(6)
        allow(sheet).to receive(:row).with(2).and_return([ '3', 'OPCO Mobilité' ])
        allow(sheet).to receive(:row).with(3).and_return([ '16', 'OPCO Mobilité' ])
        allow(sheet).to receive(:row).with(4).and_return([ '18', 'OPCO 2i' ])
        allow(sheet).to receive(:row).with(5).and_return([ 'na', 'OPCO Test' ])
        allow(sheet).to receive(:row).with(6).and_return([ 'N.A', 'OPCO Test 2' ])
      end

      it 'crée les Opcos avec leurs IDCC (normalisés à 4 chiffres)' do
        expect do
          subject.invoke
        end.to change(Opco, :count).by(2)

        opco_mobilite = Opco.find_by(nom: 'OPCO Mobilité')
        expect(opco_mobilite).to be_present
        expect(opco_mobilite.idcc).to contain_exactly('0003', '0016')

        opco_2i = Opco.find_by(nom: 'OPCO 2i')
        expect(opco_2i).to be_present
        expect(opco_2i.idcc).to contain_exactly('0018')
      end

      it 'ignore les IDCC na et N.A' do
        subject.invoke

        expect(Opco.where(nom: 'OPCO Test').count).to eq(0)
        expect(Opco.where(nom: 'OPCO Test 2').count).to eq(0)
      end

      it 'log les informations de création' do
        expect(logger).to receive(:info).with('Créé Opco : OPCO Mobilité avec 2 IDCC')
        expect(logger).to receive(:info).with('Créé Opco : OPCO 2i avec 1 IDCC')
        expect(logger).to receive(:info).with(match(/Import terminé : 2 créés, 0 mis à jour/))

        subject.invoke
      end
    end

    context 'quand un Opco existe déjà' do
      let!(:opco_existant) { create(:opco, nom: 'OPCO Mobilité', idcc: [ '99' ]) }

      before do
        allow(sheet).to receive(:last_row).and_return(3)
        allow(sheet).to receive(:row).with(2).and_return([ '3', 'OPCO Mobilité' ])
        allow(sheet).to receive(:row).with(3).and_return([ '16', 'OPCO Mobilité' ])
      end

      it 'met à jour l\'Opco existant avec les nouveaux IDCC' do
        expect do
          subject.invoke
        end.not_to change(Opco, :count)

        opco_existant.reload
        expect(opco_existant.idcc).to contain_exactly('0003', '0016')
      end

      it 'log les informations de mise à jour' do
        expect(logger).to receive(:info).with('Mis à jour Opco : OPCO Mobilité avec 2 IDCC')
        expect(logger).to receive(:info).with(match(/Import terminé : 0 créés, 1 mis à jour/))

        subject.invoke
      end
    end

    context 'avec des IDCC dupliqués pour le même Opco' do
      before do
        allow(sheet).to receive(:last_row).and_return(4)
        allow(sheet).to receive(:row).with(2).and_return([ '3', 'OPCO Mobilité' ])
        allow(sheet).to receive(:row).with(3).and_return([ '3', 'OPCO Mobilité' ]) # Duplicata
        allow(sheet).to receive(:row).with(4).and_return([ '16', 'OPCO Mobilité' ])
      end

      it 'ne crée pas de doublons d\'IDCC' do
        subject.invoke

        opco_mobilite = Opco.find_by(nom: 'OPCO Mobilité')
        expect(opco_mobilite.idcc).to contain_exactly('0003', '0016')
      end
    end

    context "quand Excel renvoie un IDCC numérique (ex. 0843 → 843), le 0 initial est restauré" do
      before do
        allow(sheet).to receive(:last_row).and_return(2)
        # 843 (Integer) simule une cellule Excel numérique : Roo supprime le 0 initial
        allow(sheet).to receive(:row).with(2).and_return([ 843, "OPCO Test 0843" ])
      end

      it "stocke l'IDCC en 0843 et non 843" do
        subject.invoke

        opco = Opco.find_by(nom: "OPCO Test 0843")
        expect(opco).to be_present
        expect(opco.idcc).to contain_exactly("0843")
      end
    end

    context 'avec des lignes vides ou sans nom d\'Opco' do
      before do
        allow(sheet).to receive(:last_row).and_return(4)
        allow(sheet).to receive(:row).with(2).and_return([ '3', 'OPCO Mobilité' ])
        allow(sheet).to receive(:row).with(3).and_return([ '16', '' ]) # Pas de nom
        allow(sheet).to receive(:row).with(4).and_return([ '', 'OPCO Test' ]) # Pas d'IDCC
      end

      it 'ignore les lignes invalides' do
        expect do
          subject.invoke
        end.to change(Opco, :count).by(1)

        expect(Opco.find_by(nom: 'OPCO Mobilité')).to be_present
        expect(Opco.where(nom: 'OPCO Test').count).to eq(0)
      end
    end
  end

  context 'quand le fichier Excel n\'existe pas' do
    before do
      allow(File).to receive(:exist?).with(chemin_fichier).and_return(false)
      allow(ImporteurOpcos).to receive(:new).and_call_original
    end

    it 'affiche une erreur et quitte' do
      expect(logger).to receive(:error).with("Fichier Excel introuvable : #{chemin_fichier}")
      expect { subject.invoke }.to raise_error(SystemExit)
    end
  end
end
