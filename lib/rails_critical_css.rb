# frozen_string_literal: true

require 'open3'
require 'rails_critical_css/version'
require 'rails_critical_css/config'
require 'rails_critical_css/actions'
require 'rails_critical_css/actions/helpers'
require 'rails_critical_css/extractor'
require 'rails_critical_css/jobs/extractor'
require 'rails_critical_css/actions/after_render'
require 'rails_critical_css/actions/before_render'
require 'rails_critical_css/helpers'

module RailsCriticalCss
  def self.config
    yield RailsCriticalCss::Config
  end
end

ActionController::Base.send(:include, RailsCriticalCss::Actions)
ActionView::Base.send(:include, RailsCriticalCss::Helpers)
