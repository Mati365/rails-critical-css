# frozen_string_literal: true

module RailsCriticalCss::Jobs
  class Extractor < ActiveJob::Base
    class << self
      def semaphore_key(cache_path)
        "semaphore-#{cache_path}"
      end

      def perform_if_semaphore_is_released(attrs)
        semaphore = semaphore_key(attrs[:cache][:path])
        return if Rails.cache.exist?(semaphore)

        Rails.cache.write(semaphore, '1', { expires_in: 15.minutes })
        perform_later(attrs)
      end
    end

    def perform(cache:, css:, html:)
      semaphore = self.class.semaphore_key(cache[:path])
      critical_css = ::RailsCriticalCss::Extractor.new(css: css, html: html).try_extract

      # store it as wrapped css, do not regenerate for
      # each request critical_css if something go wrong
      # with css-extractor
      Rails.cache.write(
        cache[:path],
        {
          css: critical_css,
        },
        cache[:store]
      )

      Rails.cache.delete(semaphore)
    end
  end
end
