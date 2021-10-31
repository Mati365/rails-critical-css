# frozen_string_literal: true
require 'rails/railtie'

module CriticalCssGenerator
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << CriticalCssGenerator
  end
end
