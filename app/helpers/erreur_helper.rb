module ErreurHelper
  def erreurs_generales(erreurs, champs_affiches)
    champs_non_affiches(erreurs.messages.keys, champs_affiches).map do |champ|
      erreurs.full_messages_for(champ)
    end.flatten
  end

  def champs_non_affiches(champs, champs_affiches)
    champs.delete_if { |champ| champs_affiches.include?(champ) }
  end
end
