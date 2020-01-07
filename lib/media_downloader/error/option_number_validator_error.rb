require File.expand_path('runtime_error.rb', __dir__)

module MediaDownloader
  module Error
    class OptionNumberValidatorError < RuntimeError
    end
  end
end