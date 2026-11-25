require "rails_helper"

describe Filtres::Periode do
  def periode(parametres)
    described_class.new(ActionController::Parameters.new(parametres), :created_at)
  end

  it "lit les bornes des prédicats de dates d'ActiveAdmin" do
    choix = periode(created_at_gteq_datetime: "2025-01-01", created_at_lteq_datetime: "2025-02-01")

    expect(choix.debut).to eq "2025-01-01"
    expect(choix.fin).to eq "2025-02-01"
  end
end
