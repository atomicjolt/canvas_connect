#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require 'adobe_connect'

require_dependency "canvas_connect/version"
require_dependency "canvas/plugins/validators/adobe_connect_validator"
require_dependency "canvas/plugins/adobe_connect"

module CanvasConnect
  class ConnectionError < StandardError; end
  class MeetingFolderError < StandardError; end

  # Public: Configure as a Canvas plugin.
  #
  # Returns nothing.
  def self.register
    Rails.configuration.to_prepare do
      view_path = File.dirname(__FILE__) + '/../app/views'
      unless ApplicationController.view_paths.include?(view_path)
        ApplicationController.view_paths.unshift(view_path)
      end

      require_dependency File.expand_path("../../models/adobe_connect_conference", File.dirname(__FILE__))

      Canvas::Plugins::AdobeConnect.new
    end
  end

  # Public: Find the plugin configuration.
  #
  # Returns a settings hash.
  def self.config
    settings = Canvas::Plugin.find('adobe_connect').settings || {}
    AdobeConnect::Config.declare do
      username settings[:username]
      password settings[:password]
      domain   settings[:domain]
    end
    settings
  end

  # Return a cached Connect Service object to make requests with.
  #
  # Returns a AdobeConnect::Service.
  def self.client
    unless @client
      settings = self.config
      connect_settings = {
        :username => settings[:login],
        :password => settings[:password_dec],
        :domain   => settings[:domain]
      }
      @client = AdobeConnect::Service.new(connect_settings)
      @client.log_in
    end

    @client
  end
end

CanvasConnect.register
