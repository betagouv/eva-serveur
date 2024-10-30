# frozen_string_literal: true

require 'rails_helper'

describe ImportQuestion do
  subject(:service) do
    described_class.new('QuestionClicDansImage')
  end

  describe '#remplis_donnees' do
    describe 'avec un fichier valide' do
      let(:file) do
        fixture_file_upload('spec/support/import_question.xls', 'text/xls')
      end

      it 'importe une nouvelle question' do
        expect do
          service.remplis_donnees(file)
        end.to change(Question, :count).by(1)
      end

      it 'crée les transcriptions' do
        service.remplis_donnees(file)
        transcriptions = Question.last.transcriptions
        expect(transcriptions.count).to eq 2
        expect(transcriptions.first.categorie).to eq 'intitule'
        expect(transcriptions.first.ecrit).to eq 'Ceci est un intitulé'
        expect(transcriptions.first.audio.attached?).to be true
        expect(transcriptions.last.categorie).to eq 'modalite_reponse'
        expect(transcriptions.last.ecrit).to eq 'Ceci est une consigne'
      end
    end

    describe 'avec un fichier invalide' do
      let(:file) do
        fixture_file_upload('spec/support/import_question_invalide.xls', 'text/xls')
      end

      it "n'importe pas de question" do
        expect do
          service.remplis_donnees(file)
        end.not_to change(Question, :count)
      end
    end
  end
end
