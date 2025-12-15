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
