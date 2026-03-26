require "rails_helper"

RSpec.describe Opco, type: :model do
  include ActiveJob::TestHelper

  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to have_one_attached(:logo) }
  it { is_expected.to have_one_attached(:visuel_offre_services) }

  describe "#supprime_visuel_offre_services" do
    let(:opco) { create(:opco) }

    before do
      opco.visuel_offre_services.attach(
        io: Rails.root.join("spec/support/programme_tele.png").open,
        filename: "visuel.png",
        content_type: "image/png"
      )
    end

    it "supprime le visuel lorsque la case est cochée" do
      perform_enqueued_jobs do
        opco.update(supprimer_visuel_offre_services: "1")
      end

      expect(opco.reload.visuel_offre_services.attached?).to be false
    end

    context "quand un nouveau visuel est envoyé en même temps que la suppression" do
      it "conserve le nouveau fichier" do
        nouvelle_image = Rack::Test::UploadedFile.new(
          Rails.root.join("spec/support/programme_tele.png")
        )

        perform_enqueued_jobs do
          opco.update(
            visuel_offre_services: nouvelle_image,
            supprimer_visuel_offre_services: "1"
          )
        end

        expect(opco.reload.visuel_offre_services.attached?).to be true
      end
    end
  end

  describe "validation url_offre_services" do
    context "quand url_offre_services est vide" do
      it "est valide" do
        opco = build(:opco, url_offre_services: nil)
        expect(opco).to be_valid
      end
    end

    context "quand url_offre_services est une URL http ou https avec host" do
      it "est valide" do
        expect(build(:opco, url_offre_services: "https://exemple.gouv.fr/offre")).to be_valid
        expect(build(:opco, url_offre_services: "http://exemple.fr")).to be_valid
      end
    end

    context "quand url_offre_services n'est pas une URL valide" do
      it "est invalide" do
        opco = build(:opco, url_offre_services: "pas une url")
        expect(opco).not_to be_valid
        expected_error = I18n.t(
          "activerecord.errors.models.opco.attributes.url_offre_services.invalid"
        )
        expect(opco.errors[:url_offre_services]).to include(expected_error)
      end
    end

    context "quand url_offre_services est une URL sans host (ex. http://)" do
      it "est invalide" do
        opco = build(:opco, url_offre_services: "http://")
        expect(opco).not_to be_valid
      end
    end

    context "quand url_offre_services utilise un schéma non http(s)" do
      it "est invalide" do
        opco = build(:opco, url_offre_services: "ftp://fichiers.exemple.fr")
        expect(opco).not_to be_valid
      end
    end
  end
end
