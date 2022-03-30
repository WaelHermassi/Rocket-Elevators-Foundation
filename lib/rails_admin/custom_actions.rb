require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
    module Config
        module Actions
            class Root < RailsAdmin::Config::Actions::Base
            RailsAdmin::Config::Actions.register(self)
                register_instance_option :root do
                    true
                end
                register_instance_option :link_icon do
                    'fa fa-bar-chart' # use any of font-awesome icons
                end
            end
            class Map < RailsAdmin::Config::Actions::Base
                RailsAdmin::Config::Actions.register(self)
                register_instance_option :root do
                    true
                end
                register_instance_option :link_icon do
                    'fa fa-map-marker' # use any of font-awesome icons
                end
            end
               
        end
    end
end