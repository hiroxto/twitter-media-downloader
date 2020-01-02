# frozen_string_literal: true

require File.expand_path('runtime_error.rb', __dir__)

module MediaDownloader
  module Error
    class AnyMediaMissingError < MediaDownloader::Error::RuntimeError
    end
  end
end
