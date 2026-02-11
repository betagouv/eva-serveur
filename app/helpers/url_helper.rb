module UrlHelper
  # https://www.constructys.fr/ => constructys.fr
  def humanize_url(url)
    url.gsub("https://", "").gsub("http://", "").gsub("www.", "").gsub("/", "")
  end
end
