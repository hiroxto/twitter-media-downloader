# frozen_string_literal: true

module MediaDownloader
  module Utils

    # ツイートの全てのメディアを MediaWrapper へ変更する
    #
    # @param [Twitter::Tweet] tweet
    # @return [Array<MediaDownloader::MediaWrapper>]
    def all_media_transform_to_media_wrapper(tweet)
      tweet.media.map.with_index { |_media, index| create_media_wrapper(tweet, index) }
    end

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
