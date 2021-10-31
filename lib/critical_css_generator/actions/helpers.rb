# frozen_string_literal: true

module CriticalCssGenerator::Actions::Helpers
  def group_assets_by_type(assets)
    return [] unless assets.present?

    assets.group_by do |item|
      item[:file].present? ? :files : :inline
    end
  end

  def eval_options(controller, packed_options)
    packed_options.transform_values do |option|
      eval_option(controller, option)
    end
  end

  def eval_option(controller, option)
    option = option.to_proc if option.is_a?(Symbol)

    if option.is_a?(Proc)
      case option.arity
      when -2, -1, 1
        controller.instance_exec(controller, &option)
      when 0
        controller.instance_exec(&option)
      end
    elsif option.respond_to?(:call)
      option.call(controller)
    else
      option
    end
  end

  def absolute_asset_file_path(controller, asset, extension = nil)
    return nil unless asset.present?

    suffix = extension ? ".#{extension}" : ''
    suffixed_asset_name = asset.include?('.') ? asset : asset + suffix

    if Rails.env.development?
      filename = controller.view_context.asset_path(suffixed_asset_name)
      File.join(Rails.public_path, filename)
    else
      File.join(Rails.public_path, Rails.application.config.assets.prefix, suffixed_asset_name)
    end
  end

  def gen_critical_css_cache_path(options, path)
    return nil unless path

    controller, action = @controller.request.path_parameters.values_at(:controller, :action)
    path = eval_option(controller, path)

    "#{options[:cache_prefix]}-#{controller}##{action}#{path}"
  end
end
