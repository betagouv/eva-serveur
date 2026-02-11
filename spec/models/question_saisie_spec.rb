require 'rails_helper'

describe QuestionSaisie, type: :model do
  it { is_expected.to have_many(:reponses).with_foreign_key(:question_id) }

  describe '#as_json' do
    let(:question_saisie) do
      create(:question_saisie,
             transcription_ecrit: 'Mon Intitulé',
             reponse_placeholder: 'écrivez ici',
             type_saisie: 'texte',
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             ),
             aide: 'Aide')
    end
    let!(:modalite) do
      create(:transcription, :avec_audio, question_id: question_saisie.id,
                                          categorie: :modalite_reponse)
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_saisie.id) }
    let!(:reponse2) { create(:choix, :bon, question_id: question_saisie.id) }
    let(:json) { question_saisie.as_json }

    before do
      Transcription.find_by(categorie: :intitule, question_id: question_saisie.id)
                   .update(audio: Rack::Test::UploadedFile.new(
                     Rails.root.join('spec/support/alcoolique.mp3')
                   ))
    end

    it 'serialise les champs' do
      expect(json.keys).to match_array(%w[id intitule audio_url nom_technique suffix_reponse
                                          description illustration modalite_reponse type sous_type
                                          placeholder reponses texte_a_trous consigne_audio
                                          demarrage_audio_modalite_reponse aide score
                                          metacompetence max_length passable])
      expect(json['type']).to eql('saisie')
      expect(json['sous_type']).to eql('texte')
      expect(json['placeholder']).to eql('écrivez ici')
      expect(json['intitule']).to eql('Mon Intitulé')
      expect(json['reponses'][0]['intitule']).to eql(reponse.intitule)
      expect(json['reponses'][0]['type_choix']).to eql('bon')
      expect(json['modalite_reponse']).to eql(modalite.ecrit)
      expect(json['aide']).to eql('Aide')
    end

    it "retourne l'illustration" do
      expect(json['illustration']).to eql(Rails.application.routes.url_helpers.url_for(
                                            question_saisie.illustration.variant(:defaut)
                                          ))
    end

    context "quand il n'y a pas de réponse" do
      it 'ne retourne pas de reponse' do
        reponse.destroy
        expect(json['reponse']).to be_nil
      end
    end

    describe '#bonnes_reponses' do
      it 'retourne les bonnes réponses' do
        expect(question_saisie.bonnes_reponses).to eql('bon choix | bon choix')
      end
    end
  end

  describe '#parametre_nombre_avec_virgule' do
    context 'sans reponse_placeholder et suffix_reponse spécifiés' do
      let(:question_saisie) { create(:question_saisie, type_saisie: 'nombre_avec_virgule') }

      it 'paramétre les champs par défaut' do
        question_saisie.parametre_nombre_avec_virgule
        expect(question_saisie.reponse_placeholder).to eql('0,00')
        expect(question_saisie.suffix_reponse).to eql('€')
      end
    end

    context 'avec reponse_placeholder et suffix_reponse spécifiés' do
      let(:question_saisie) do
        create(:question_saisie, type_saisie: 'nombre_avec_virgule', reponse_placeholder: '1.000',
                                 suffix_reponse: '$')
      end

      it 'ne met pas à jour les champs si ils sont déjà renseignés' do
        expect(question_saisie.reponse_placeholder).to eql('1.000')
        expect(question_saisie.suffix_reponse).to eql('$')
      end
    end

    context 'quand le type de saisie n est pas nombre_avec_virgule' do
      let(:question_saisie) { create(:question_saisie, type_saisie: 'texte') }

      it 'ne met pas à jour les champs' do
        expect(question_saisie.reponse_placeholder).to be_nil
        expect(question_saisie.suffix_reponse).to be_nil
      end
    end
  end
end
