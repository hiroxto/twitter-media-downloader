# frozen_string_literal: true

module MediaDownloader
  class IDParser

    # @return [String]
    attr_reader :raw_data

    # @param [String] raw_data パースするID
    def initialize(raw_data)
      @raw_data = raw_data
    end
  end
end
