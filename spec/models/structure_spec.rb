require 'rails_helper'

describe Structure, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_uniqueness_of(:nom).scoped_to(:code_postal).case_insensitive }
  it { is_expected.to validate_numericality_of(:siret) }

  describe 'Ancestry primary key format' do
    it { expect('uuid invalide').not_to match(Ancestry.default_primary_key_format) }
    it { expect(SecureRandom.uuid).to match(Ancestry.default_primary_key_format) }
  end

  context 'quand une structure avec le même nom, même CP, a été soft-deleted' do
    let(:structure) { build :structure, nom: 'nom', code_postal: '75012' }

    before do
      structure_existante_effacee = create :structure, nom: 'nom', code_postal: '75012'
      structure_existante_effacee.destroy
    end

    it "Peut ré-utiliser le nom d'une structure effacé" do
      expect(structure.save).to be true
    end
  end

  def mock_geo_api(departement, code_region, region)
    mock_reponse_typhoeus("https://geo.api.gouv.fr/departements/#{departement}",
                          { codeRegion: code_region })

    mock_reponse_typhoeus("https://geo.api.gouv.fr/regions/#{code_region}",
                          { nom: region })
  end

  describe 'géolocalisation à la validation' do
    describe "pour n'importe quel code postal" do
      let(:structure) { described_class.new code_postal: '75012' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '75012', [ { 'coordinates' => [ 40.7143528, -74.0059731 ] } ]
        )
        mock_geo_api(75, 11, 'Île-de-France')
        structure.valid?
      end

      it do
        expect(structure.latitude).to be(40.7143528)
        expect(structure.longitude).to be(-74.0059731)
        expect(structure.region).to eql('Île-de-France')
      end

      it { expect(described_class.geocoder_options[:params]).to include(countrycodes: 'fr') }
    end

    describe 'si ma structure a un code postal commençant par 988' do
      let(:structure) { described_class.new code_postal: '98850' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '98850', [
            {
              'coordinates' => [ 47.3129, 120.0596 ]
            }
          ]
        )
        mock_geo_api(988, 988, 'Nouvelle-Calédonie')
        structure.valid?
      end

      it 'lui attribue la région Nouvelle-Calédonie' do
        expect(structure.region).to eql('Nouvelle-Calédonie')
      end
    end

    describe 'si ma structure a un code postal commençant par 20' do
      let(:structure) { described_class.new code_postal: '20090' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '20090', [ { 'coordinates' => [ 41.9333, 8.7507 ] } ]
        )
        mock_geo_api('2A', 94, 'Corse')
        structure.valid?
      end

      it 'lui attribue la région Corse' do
        expect(structure.region).to eql('Corse')
      end
    end

    context 'quand ma structure a déjà une région' do
      let(:structure) { described_class.new code_postal: '20114', region: 'Corse' }

      before do
        structure.code_postal = '61000'
        Geocoder::Lookup::Test.add_stub(
          '61000', [
            {
              'coordinates' => [ 48.4310232, 0.0922579 ]
            }
          ]
        )
        mock_geo_api(61, 28, 'Normandie')
        structure.valid?
      end

      it 'lui attribue la nouvelle région' do
        expect(structure.region).to eql('Normandie')
      end
    end
  end

  describe 'à la création' do
    it 'programme un mail de relance' do
      expect { create :structure }
        .to have_enqueued_job(RelanceStructureSansCampagneJob).exactly(1)
    end
  end

  describe 'validation du champ siret' do
    context 'quand il est vide' do
      let(:structure) { build :structure }

      before { structure.valid? }

      it { expect(structure.errors[:siret]).to be_blank }
    end

    context 'quand il est un siret valide avec des espaces' do
      let(:structure) { build :structure, siret: '1234567890 1234' }

      before { structure.valid? }

      it do
        expect(structure.errors[:siret]).to be_blank
        expect(structure.siret).to eq('12345678901234')
      end
    end

    context 'quand il est un siret valide (14 chiffres)' do
      let(:structure) { build :structure, siret: '12345678901234' }

      before { structure.valid? }

      it { expect(structure.errors[:siret]).to be_blank }
    end

    context 'quand il est un siren valide (9 chiffres)' do
      let(:structure) { build :structure, siret: '123456789' }

      before { structure.valid? }

      it { expect(structure.errors[:siret]).to be_blank }
    end

    context 'quand il est invalide' do
      let(:structure) { build :structure, siret: '12345678' }

      before { structure.valid? }

      it do
        expect(structure.errors[:siret])
          .to include(I18n.t('activerecord.errors.models.structure.attributes.siret.invalid'))
      end
    end
  end
end
