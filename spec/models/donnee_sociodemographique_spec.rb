require 'rails_helper'

describe DonneeSociodemographique, type: :model do
  it { is_expected.to belong_to(:evaluation) }

  it do
    subject.evaluation = create(:evaluation)
    expect(subject).to validate_uniqueness_of(:evaluation_id).case_insensitive
  end

  it do
    genres = DonneeSociodemographique::GENRES.zip(DonneeSociodemographique::GENRES).to_h
    expect(subject).to define_enum_for(:genre).with_values(genres)
                                              .backed_by_column_of_type(:string)
  end

  it do
    niveaux_etudes = DonneeSociodemographique::NIVEAUX_ETUDES
                     .zip(DonneeSociodemographique::NIVEAUX_ETUDES).to_h
    expect(subject).to define_enum_for(:dernier_niveau_etude).with_values(niveaux_etudes)
                                                             .backed_by_column_of_type(:string)
  end

  it do
    situations = DonneeSociodemographique::SITUATIONS.zip(DonneeSociodemographique::SITUATIONS).to_h
    expect(subject).to define_enum_for(:derniere_situation).with_values(situations)
                                                           .backed_by_column_of_type(:string)
  end
end
