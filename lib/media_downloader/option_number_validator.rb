# frozen_string_literal: true

module MediaDownloader
  class OptionNumberValidator

    # @param [Twitter::Tweet] tweet
    # @param [Array<Integer>] numbers
    def initialize(tweet, numbers)
      @tweet = tweet
      @medias = @tweet.media
      @numbers = numbers
    end
  end
end
