require "unrar/version"
require 'fileutils'
require 'tmpdir'

module Unrar
  class Archive
    SEARCH_PATH = ["/usr/local/bin", "/usr/bin", "/bin", "/opt/local/bin"]

    attr_accessor :file, :tmpdir

    def initialize(file, destination = nil)
      self.file = file
      self.tmpdir = destination || Dir.mktmpdir

      # shitty clean up; fix this
      at_exit {
        FileUtils.rm_rf self.tmpdir
      }

      unless File.readable? file
        raise "Cannot read #{file}!"
      end
    end

    def extract(*filenames)
      cmd = "#{Archive.unrar} -y x '#{rar_path}' #{filenames.join(" ")} #{tmpdir}/"

      if system(cmd)
        Dir["#{tmpdir}/**/*"].to_ary
      else
        false
      end
    end

    def list
      items = []
      cmdoutput = `#{Archive.unrar} l '#{rar_path}'`
      cmdoutput.each_line do |line|
        items << line.strip
      end

      items
    end

    def self.unrar
      @@unrar ||= search_for "unrar"
    end

    def rar_path
      @rar_path ||= file.respond_to?(:path) ? file.path : file
    end

    private

    def self.search_for file
      SEARCH_PATH.find do |path|
        return "#{path}/#{file}" if File.exists? "#{path}/#{file}"
      end
    end
  end
end
