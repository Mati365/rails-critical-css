# frozen_string_literal: true
require 'rails/railtie'

module RailsCriticalCss
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << RailsCriticalCss
  end
end
