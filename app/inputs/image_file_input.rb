class ImageFileInput < FileInput
  include StorageHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Context

  private

  def label_html
    super + image_preview_html
  end

  def image_preview_html
    return "".html_safe unless object.send(method).attached?

    template.content_tag(:div,
      image_preview_tag.html_safe,
      class: "image-preview-container"
    )
  end

  def image_preview_tag
    image_tag(cdn_for(object.send(method)),
              alt: object.send(method).filename,
              class: "image-preview")
  end

  def file_input_html
    input_html = get_input_html_options
    field = builder.file_field(method, input_html)

    template.content_tag(:div, class: "image-file-input-with-clear") do
      template.safe_join([ field, clear_button_html ])
    end
  end

  def clear_button_html
    label = I18n.t("formtastic.inputs.image_file.retirer_fichier_selectionne")

    template.content_tag(:button,
      template.content_tag(:span, "", class: "fr-icon-close-line", "aria-hidden": "true"),
      type: "button",
      class: "image-file-input-with-clear__btn fr-btn fr-btn--tertiary-no-outline fr-btn--sm",
      hidden: true,
      title: label,
      "aria-label": label,
      "data-image-file-clear": "")
  end

  def get_input_html_options
    input_html = super
    input_html[:accept] ||= "image/*"
    input_html
  end

  def hint_text
    hint = super
    hint ||= "Formats acceptés : .jpg, .png, .svg, .webp"
    hint
  end
end
