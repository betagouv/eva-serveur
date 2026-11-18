require 'rails_helper'

require 'active_admin/actions_items_sidebar/resource_extension'

class MaResource
  attr_accessor :presenter_index, :namespace

  def sidebar_sections
    @sidebar_sections ||= []
  end

  def action_items
    @action_items ||= []
  end

  def add_action_item(name, options = {}, &)
    action_items << ActiveAdmin::ActionItem.new(name, options, &)
  end

  def get_page_presenter(_action)
    presenter_index
  end

  include ActiveAdmin::ActionsItemsSidebar::ResourceExtension
end

RSpec.describe ActiveAdmin::ActionsItemsSidebar::ResourceExtension do
  let(:ma_resource) { MaResource.new }
  let(:sidebar_sections) { ma_resource.sidebar_sections }

  before { ma_resource.namespace = double(download_links: %i[xls json]) }

  it do
    expect(sidebar_sections.length).to eq 1
    expect(sidebar_sections.first.name).to eq 'action_items'
  end

  it "ajoute l'action de téléchargement XLS sur l'index" do
    action_item = ma_resource.action_items.find { |item| item.name == :telechargement_xls }
    expect(action_item.display_on?(:index, double(params: {}))).to be true
    expect(action_item.display_on?(:show)).to be false
  end

  describe '#telechargement_xls_disponible?' do
    let(:contexte_vue) { double(params: { action: 'index' }) }

    def disponible?
      ma_resource.telechargement_xls_disponible?(contexte_vue)
    end

    it "est disponible avec les liens de téléchargement de l'espace de noms" do
      expect(disponible?).to be true
    end

    it "n'est pas disponible quand l'espace de noms ne propose pas le XLS" do
      ma_resource.namespace = double(download_links: %i[json])
      expect(disponible?).to be false
    end

    it "est disponible quand l'index liste le XLS" do
      ma_resource.presenter_index = ActiveAdmin::PagePresenter.new(download_links: %i[json xls])
      expect(disponible?).to be true
    end

    it "évalue les liens de téléchargement de l'index dans le contexte de la vue" do
      ma_resource.presenter_index = ActiveAdmin::PagePresenter.new(
        download_links: -> { params[:action] == 'show' ? %i[pdf] : %i[xls] }
      )
      expect(disponible?).to be true
    end

    it "n'est pas disponible quand l'index désactive les liens de téléchargement" do
      ma_resource.presenter_index = ActiveAdmin::PagePresenter.new(download_links: false)
      expect(disponible?).to be false
    end

    it "n'est pas disponible quand l'index ne liste pas le XLS" do
      ma_resource.presenter_index = ActiveAdmin::PagePresenter.new(download_links: %i[json])
      expect(disponible?).to be false
    end
  end
end
