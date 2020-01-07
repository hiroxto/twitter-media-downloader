# frozen_string_literal: true

module MediaDownloader
  module Utils

    # MediaWrapper のインスタンスを作成する
    #
    # @param [Twitter::Tweet] tweet
    # @param [Integer] index
    # @return [MediaDownloader::MediaWrapper]
    def create_media_wrapper(tweet, index)
      medias = tweet.media
      MediaWrapper.new(tweet, medias[index], index)
    end

  end
end
