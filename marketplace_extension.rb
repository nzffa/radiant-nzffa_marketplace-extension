# Uncomment this if you reference any of your controllers in activate
# require_dependency "application_controller"
require "radiant-marketplace-extension"

class MarketplaceExtension < Radiant::Extension
  version     RadiantMarketplaceExtension::VERSION
  description RadiantMarketplaceExtension::DESCRIPTION
  url         RadiantMarketplaceExtension::URL

  # See your config/routes.rb file in this extension to define custom routes

  extension_config do |config|
    # config is the Radiant.configuration object
  end

  def activate
    # this seem to work as a method to overwrite the readers views
    Page.class_eval { include Marketplace }
    tab 'Marketplace' do
      add_item "Marketplace", "/admin/adverts"
    end
  end
end
