class AjoutePositionAParcoursTypes < ActiveRecord::Migration[7.2]
  def up
    add_column :parcours_type, :position, :integer
    ParcoursType::TYPES_DE_PROGRAMME.each do |programme|
      position = 0
      ParcoursType.order(:created_at).send(programme).find_each do |pt|
        pt.update(position: position)
        position += 1
      end
    end
  end

  def down
    remove_column :parcours_type, :position, :integer
  end
end
