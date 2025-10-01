require 'rails_helper'

describe ErreurHelper do
  describe '#erreurs_generales' do
    let(:erreurs) { double }
    let(:messages) { { email: 'doit exister', nom: "n'est pas unique" } }

    it 'Retourne les erreurs qui ne concerne pas les champs affichés' do
      allow(erreurs).to receive(:messages).and_return(messages)
      allow(erreurs).to receive(:full_messages_for).with(:nom)
        .and_return([ "nom n'est pas unique" ])
      expect(erreurs_generales(erreurs, [ :email ])).to eql([ "nom n'est pas unique" ])
    end

    it "Retourne aucune erreur s'il n'y a pas d'erreur" do
      allow(erreurs).to receive(:messages).and_return({})
      expect(erreurs_generales(erreurs, [])).to eql([])
    end
  end
end
