class PanelComponent < ViewComponent::Base
  def initialize(titre:, classes: "")
    @titre = titre
    @classes = classes
  end
end
