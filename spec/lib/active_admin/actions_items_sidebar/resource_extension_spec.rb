require 'rails_helper'

require 'active_admin/actions_items_sidebar/resource_extension'

class MaResource
  def sidebar_sections
    @sidebar_sections ||= []
  end

  include ActiveAdmin::ActionsItemsSidebar::ResourceExtension
end

RSpec.describe ActiveAdmin::ActionsItemsSidebar::ResourceExtension do
  let(:sidebar_sections) { MaResource.new.sidebar_sections }

  it do
    expect(sidebar_sections.length).to eq 1
    expect(sidebar_sections.first.name).to eq 'action_items'
  end
end
