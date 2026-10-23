class SelectionMultipleFilterInput < ActiveAdmin::Inputs::Filters::CheckBoxesInput
  def choices_group_wrapping(&)
    template.content_tag(:details, class: "selection-multiple",
                                   data: { modele_resume: I18n.t(options[:cle_resume],
                                                                 count: "%{count}") }) do
      template.content_tag(:summary, resume, class: "selection-multiple__resume") +
        template.content_tag(:div, template.capture(&), class: "selection-multiple__liste")
    end
  end

  private

  def resume
    choisis = collection.select { |(_libelle, valeur)| valeurs_choisies.include?(valeur.to_s) }
    return "" if choisis.empty?
    return choisis.first.first if choisis.one?

    I18n.t(options[:cle_resume], count: choisis.size)
  end

  def valeurs_choisies
    Array(selected_values).map(&:to_s)
  end
end
