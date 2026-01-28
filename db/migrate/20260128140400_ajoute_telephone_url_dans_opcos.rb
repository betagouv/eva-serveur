class AjouteTelephoneUrlDansOpcos < ActiveRecord::Migration[7.2]
  def change
    add_column :opcos, :telephone, :string
    add_column :opcos, :url, :string
  end
end
