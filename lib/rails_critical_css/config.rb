# frozen_string_literal: true

module RailsCriticalCss
  class Config
    class << self
      attr_writer :width, :height, :keep_larger_media_queries,
                  :render_wait_time, :penthouse_options

      def width
        @width ||= 1200
      end

      def height
        @height ||= 900
      end

      def render_wait_time
        @render_wait_time ||= 2000
      end

      def keep_larger_media_queries
        @keep_larger_media_queries ||= false
      end

      def as_json_config(props = {})
        {
          width: width,
          height: height,
          keepLargerMediaQueries: keep_larger_media_queries,
          renderWaitTime: render_wait_time,
        }
          .merge!(@penthouse_options || {})
          .merge!(props)
      end
    end
  end
end
