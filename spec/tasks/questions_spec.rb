# frozen_string_literal: true

require 'rails_helper'

describe 'questions:attache_assets' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }
  let!(:question) { create :question_qcm, nom_technique: 'lodi_1' }
  let!(:transcription) { create :transcription, question_id: question.id, categorie: :intitule }
  let!(:choix) { create :choix, :bon, question_id: question.id, nom_technique: 'LOdi/couverture' }
  let!(:choix2) do
    create :choix, :mauvais, question_id: question.id, nom_technique: 'ALrd/jazz_a_dimoudon'
  end

  before do
    allow(logger).to receive :info
    subject.invoke
  end

  context "attache l'illustration à la question correspondante" do
    it { expect(question.reload.illustration.attached?).to be true }
  end

  context "attache l'audio à l'intitulé de la question correspondante" do
    it { expect(question.reload.transcription_intitule.audio.attached?).to be true }
  end

  context "attache l'audio aux choix de la question correspondante" do
    it { expect(question.reload.choix[0].audio.attached?).to be true }
    it { expect(question.reload.choix[1].audio.attached?).to be true }
  end
end
