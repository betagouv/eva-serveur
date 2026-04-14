module UrlHelper
  # https://www.constructys.fr/ => constructys.fr
  def humanize_url(url)
    url.gsub("https://", "").gsub("http://", "").gsub("www.", "").delete_suffix("/")
  end
end
