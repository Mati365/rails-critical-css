# frozen_string_literal: true

module CriticalCssGenerator::Actions
  class AfterRender
    include CriticalCssGenerator::Actions::Helpers

    def initialize(filter_options)
      @packed_options = filter_options.slice(
        :css, :cache_key, :cache_store, :cache_prefix
      )
    end

    def after(controller)
      return if controller.critical_css_cache.present?

      @controller = controller
      options = eval_options(controller, @packed_options)
      cache_path = gen_critical_css_cache_path(options, options[:cache_key])

      return if cache_path == false

      CriticalCssGenerator::Jobs::Extractor.perform_if_semaphore_is_released(
        html: controller.full_html_response,
        cache: {
          path: cache_path,
          store: options[:cache_store],
        },
        css: {
          assets: assets_mapped_paths,
        },
      )
    end

    private

      def assets_mapped_paths
        items = group_assets_by_type(@controller.critical_css_assets)
        output = items[:inline] || []

        if items[:files]
          output += items[:files].map do |i|
            file = Rails.env.development? ? i[:file] : Rails.application.assets_manifest.assets["#{i[:file]}.css"]

            {
              critical: i[:critical],
              file: absolute_asset_file_path(@controller, file, 'css')
            }
          end
        end

        output
      rescue
        []
      end
  end
end
