# frozen_string_literal: true

describe ImportExport::IterateurCellules do
  it "permet de parcours les cellues d'une ligne dans l'ordre" do
    iterateur = described_class.new([ 1, 2, 3 ])
    expect(iterateur.suivant).to eq(1)
    expect(iterateur.suivant).to eq(2)
    expect(iterateur.suivant).to eq(3)
  end

  it "Peut retourner la valeur d'une cellule" do
    iterateur = described_class.new([ 1, 2, 3 ])
    expect(iterateur.cell(2)).to eq(3)
  end
end
