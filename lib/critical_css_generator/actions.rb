# frozen_string_literal: true

module CriticalCssGenerator::Actions
  extend ActiveSupport::Concern

  included do
    include CriticalCssGenerator::Helpers

    attr_accessor :lazy_css_blocks,
                  :critical_css_assets,
                  :critical_css_cache,
                  :critical_css_enabled

    helper_method :append_critical_css_asset,
                  :append_css_tags_assets
  end

  def extract_assets_from_css_tags(str)
    return [] unless str.present?

    str
      .scan(/assets\/([^?"]*)-[^?-]+.css/)
      .flatten
      .map { |i| i.sub('.self', '') }
  end

  def append_critical_css_asset(file:, critical: false)
    (@critical_css_assets ||= []) << {
      file: file,
      critical: critical,
    }
  end

  def append_css_tags_assets(str)
    extract_assets_from_css_tags(str).each do |asset|
      append_critical_css_asset file: asset
    end
  end

  def full_html_response
    response.body
  end

  class_methods do
    def action_critical_css(*actions)
      options = actions.extract_options!
      return unless cache_configured?

      options[:unless] ||= -> { request.query_string.present? }
      options[:cache_prefix] ||= 'critical-css'

      filter_options = options.extract!(:if, :unless).merge(only: actions)
      around_action CriticalCssGenerator::Actions::BeforeRender.new(options), filter_options
      after_action CriticalCssGenerator::Actions::AfterRender.new(options), filter_options
    end
  end
end
