# frozen_string_literal: true

module CriticalCssGenerator::Actions
  class BeforeRender
    include CriticalCssGenerator::Actions::Helpers

    def initialize(filter_options)
      @packed_options = filter_options.slice(:css, :cache_key, :cache_prefix)
    end

    def around(controller)
      @controller = controller

      options = eval_options(controller, @packed_options)
      cache_path = gen_critical_css_cache_path(options, options[:cache_key])

      # load already compiled css from cache
      critical_css_cache = cache_path.presence && Rails.cache.read(cache_path)
      controller.critical_css_cache = critical_css_cache
      controller.critical_css_enabled = true

      yield
      return unless css_extracting_allowed?

      if critical_css_cache.present? && critical_css_cache[:lazy_css_blocks].present?
        controller.response.body = inject_lazy_css_to_footer(critical_css_cache[:lazy_css_blocks])
      end
    end

    private

      def css_extracting_allowed?
        @controller.request.get? \
          && @controller.response.status == 200 \
          && @controller.full_html_response.present?
      end

      def inject_lazy_css_to_footer(css)
        html = @controller.full_html_response
        lazy_css_injection_index = html.index('</body>')

        [
          html[0..lazy_css_injection_index - 1],
          css,
          html[lazy_css_injection_index..-1],
        ].join('')
      end
  end
end
