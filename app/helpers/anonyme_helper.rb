# frozen_string_literal: true

module AnonymeHelper
  def nom_pour_evaluation(evaluation)
    prefixe_anonyme = evaluation.anonyme? ? "#{svg_anonyme} ".html_safe : ''
    prefixe_anonyme + evaluation.nom
  end

  private

  def svg_anonyme
    file_path = "#{Rails.root}/app/assets/images/anonyme.svg"
    if File.exist?(file_path)
      File.read(file_path).html_safe
    else
      ''
    end
  end
end
