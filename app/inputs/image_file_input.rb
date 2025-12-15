class ImageFileInput < Formtastic::Inputs::FileInput
  include StorageHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Context

  def hint_html
    if object.send(method).attached?
      image_tag(cdn_for(object.send(method)),
                alt: object.send(method).filename,
                class: "image-preview")
    else
      hint_text
    end
  end

  def input_html_options
    options = super
    options[:accept] ||= "image/*"
    options
  end
end
