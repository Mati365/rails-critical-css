# frozen_string_literal: true

module RailsCriticalCss::Helpers
  def critical_css
    @critical_css_cache.try(:[], :css)
  end

  def critical_css_enabled?
    @critical_css_enabled
  end

  def critical_css?
    critical_css.present? && critical_css.instance_of?(String)
  end

  def critical_css_asset(attrs)
    append_critical_css_asset(attrs)
    nil
  end

  def critical_css_tags(preserve_content: true, &block)
    content = capture(&block)

    if critical_css_enabled? && critical_css?
      css_tags = content_tag(:style, critical_css.html_safe, type: 'text/css')
      css_tags = "#{css_tags}#{content}".html_safe if preserve_content
      css_tags.html_safe
    else
      append_css_tags_assets(content)
      content
    end
  end

  def critical_css_link(href, media: nil)
    if critical_css?
      link_to(href: href, rel: 'preload', as: 'style', media: media, onload: "this.rel = 'stylesheet'")
    else
      append_css_tags_assets do
        link_to(href: href, rel: 'stylesheet', media: media)
      end
    end
  end
end
