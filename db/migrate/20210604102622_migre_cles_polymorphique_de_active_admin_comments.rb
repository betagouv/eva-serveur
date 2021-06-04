class MigreClesPolymorphiqueDeActiveAdminComments < ActiveRecord::Migration[6.1]
  def change
    id_to_uuid_polymorphic('active_admin_comments', ActiveAdmin::Comment, 'author')
  end

  def id_to_uuid_polymorphic(table_name, klass, relation_name)
    table_name = table_name.to_sym
    foreign_key = "#{relation_name}_id".to_sym
    new_foreign_key = "#{relation_name}_uuid".to_sym

    add_column table_name, new_foreign_key, :uuid

    klass.where.not(foreign_key => nil).each do |record|
      relation_klass = record.send("#{relation_name}_type").classify.constantize
      if associated_record = relation_klass.find_by(id: record.send(foreign_key))
        record.update_column(new_foreign_key, associated_record.uuid)
      end
    end

    remove_column table_name, foreign_key
    rename_column table_name, new_foreign_key, foreign_key
  end
end
