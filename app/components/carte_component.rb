class CarteComponent < ViewComponent::Base
  def initialize(url, classes: nil)
    @url = url
    @classes = classes
  end
end
