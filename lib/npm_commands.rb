# frozen_string_literal: true

class NpmCommands
  def install(*args)
    return false unless check_nodejs_installed
    STDERR.puts 'Installing npm dependencies...'

    install_status = Dir.chdir File.expand_path('..', File.dirname(__FILE__)) do
      system('npm', 'install', *args)
    end

    STDERR.puts(
      *if install_status
         ['npm dependencies installed']
       else
         ['-' * 60,
          'Error: npm dependencies installation failed',
          '-' * 60]
       end
    )

    install_status
  end
end
