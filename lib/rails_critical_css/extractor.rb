# frozen_string_literal: true

require 'open3'
require 'json'

module RailsCriticalCss
  LIB_ROOT = File.expand_path(File.join('..'), File.dirname(__FILE__))

  class Extractor
    include RailsCriticalCss::Actions::Helpers

    def initialize(options)
      @html, @css = options.values_at(:html, :css)
    end

    def try_extract
      tmp_html_file = tmp_extractor_file(@html, extension: 'html')
      tmp_css_file = tmp_concat_assets_array(@css[:assets], extension: 'css')
      return nil unless tmp_html_file.present? && tmp_css_file.present?

      stdout, stderr = Dir.chdir(LIB_ROOT) do
        Open3.capture2e(
          'node js/css-extractor.js',
          stdin_data: Extractor.extractor_process_input(
            html_path: tmp_html_file.path,
            css_path: tmp_css_file.path,
          )
        )
      end

      if stderr.try(:success?) && !stdout.try(:include?, 'UnhandledPromiseRejectionWarning')
        [
          extract_critical_assets(@css[:assets]),
          stdout.try(:gsub, /src:[^;]+;/, ''),
        ].join(' ')
      else
        nil
      end
    rescue
      nil
    ensure
      tmp_html_file&.delete
      tmp_css_file&.delete
    end

    def self.extractor_process_input(html_path:, css_path:)
      config = ::RailsCriticalCss::Config.as_json_config({
        url: "file://#{html_path}",
        css: css_path,
      })

      JSON.generate(config)
    end

    private

      def extract_critical_assets(assets)
        return '' unless assets.present?

        critical_assets = assets.filter { |item| item[:critical] }
        critical_assets
          .map { |asset| File.read(asset[:file]) }
          .compact
          .join(' ')
      end

      def tmp_dir
        File.join(Rails.root, 'tmp')
      end

      def tmp_extractor_file(content = nil, extension: nil)
        f = Tempfile.new(['critical-css-tmp', ".#{extension || 'bin'}"], tmp_dir, encoding: 'utf-8')
        if content.present?
          f.write(content)
          f.rewind
        end

        f.close
        f
      end

      def tmp_concat_assets_array(assets, extension: nil)
        return nil unless assets.present?

        items = group_assets_by_type(assets)
        file = tmp_extractor_file(
          (items[:inline] || []).join('\n'),
          extension: extension
        )

        paths = (items[:files] || []).map { |asset| asset[:file] }.compact
        unless paths.empty?
          Open3.pipeline_w(['cat', *paths], out: file.path)
        end

        file
      end
  end
end
