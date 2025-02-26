# frozen_string_literal: true

module ImportExport
  class IterateurCellules
    def initialize(cellules)
      @cellules = cellules
      @index = -1
    end

    def suivant
      @cellules[@index += 1]
    end

    def cell(index)
      @cellules[index]
    end
  end
end
