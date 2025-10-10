class PasseUsageAvecLaValeurParDefaut < ActiveRecord::Migration[7.2]
  def up
    StructureLocale.where(usage: nil).update_all(usage: "Eva: bénéficiaires")
  end

  def down
    StructureLocale.where(usage: "Eva: bénéficiaires").update_all(usage: nil)
  end
end
