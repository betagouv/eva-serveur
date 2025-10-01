require 'rails_helper'

describe QuestionQcm, type: :model do
  it { is_expected.to have_many(:choix).order(position: :asc).with_foreign_key(:question_id) }

  describe "accesseurs des réponses pour l'export" do
    let(:choix1) do
      create :choix, :bon, nom_technique: 'choix_1', intitule: 'intitule1'
    end

    let(:choix2) { create :choix, :bon, nom_technique: 'choix_2', intitule: '' }
    let(:choix3) { create :choix, :mauvais, nom_technique: 'choix_3', intitule: '' }

    let(:question_qcm) { create(:question_qcm, choix: [ choix1, choix2, choix3 ]) }
    let(:question_qcm_sans_bonne_reponses) { create(:question_qcm, choix: [ choix3 ]) }

    describe '#reponses_possibles' do
      it "retourne l'intitulé ou le nom technique a défaut" do
        expect(question_qcm.reponses_possibles).to eq('intitule1 | choix_2 | choix_3')
      end
    end

    describe '#bonnes_reponses' do
      it "retourne l'intitulé ou le nom technique a défaut" do
        expect(question_qcm.bonnes_reponses).to eq('intitule1 | choix_2')
      end

      it "retourne vide s'il n'y a pas de bonnes réponses" do
        expect(question_qcm_sans_bonne_reponses.bonnes_reponses).to eq('')
      end
    end

    describe '#intitule_reponse' do
      it "retourne l'intitulé s'il est présent" do
        expect(question_qcm.intitule_reponse(choix1.id)).to eq('intitule1')
      end

      it "retourne le nom technique s'il n'y a pas d'intitulé" do
        expect(question_qcm.intitule_reponse(choix2.id)).to eq('choix_2')
      end

      it "retourne le parametre si ce n'est pas un identifiant" do
        expect(question_qcm.intitule_reponse('texte reponse')).to eq('texte reponse')
      end
    end
  end

  describe '#as_json' do
    let(:question_qcm) do
      create(:question_qcm, illustration: Rack::Test::UploadedFile.new(
        Rails.root.join('spec/support/programme_tele.png')
      ))
    end

    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_qcm.id,
                                          categorie: :modalite_reponse,
                                          ecrit: 'Ma modalité')
    end

    it 'serialise les champs' do
      intitule = create(:transcription, :avec_audio, question_id: question_qcm.id,
                                                     ecrit: 'Mon Intitulé')
      choix = create(:choix, :bon, :avec_audio, question_id: question_qcm.id)

      json = question_qcm.as_json
      expect(json.keys)
        .to match_array(%w[choix description id intitule audio_url nom_technique type metacompetence
                           type_qcm illustration modalite_reponse consigne_audio
                           demarrage_audio_modalite_reponse score])
      expect(json['type']).to eql('qcm')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_qcm.illustration.variant(:defaut)
                                          ))
      expect(json['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                         intitule.audio
                                       ))
      expect(json['choix'][0]['audio_url']).to eql(Rails.application.routes.url_helpers.url_for(
                                                     choix.audio
                                                   ))
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
    end
  end
end
