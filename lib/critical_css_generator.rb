# frozen_string_literal: true

require 'open3'
require 'critical_css_generator/config'
require 'critical_css_generator/actions'
require 'critical_css_generator/actions/helpers'
require 'critical_css_generator/extractor'
require 'critical_css_generator/jobs/extractor'
require 'critical_css_generator/actions/after_render'
require 'critical_css_generator/actions/before_render'
require 'critical_css_generator/helpers'

module CriticalCssGenerator
  def self.config
    yield CriticalCssGenerator::Config
  end
end

ActionController::Base.send(:include, CriticalCssGenerator::Actions)
ActionView::Base.send(:include, CriticalCssGenerator::Helpers)
