class RemetIndexActiveAdminComment < ActiveRecord::Migration[6.1]
  def change
    add_index 'active_admin_comments', ["author_type", "author_id"]
  end
end
