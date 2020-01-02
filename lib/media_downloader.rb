# frozen_string_literal: true

module MediaDownloader
end

Dir[File.join(__dir__, '/**/*.rb')].sort.each do |file|
  require File.expand_path(file)
end
