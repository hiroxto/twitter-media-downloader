# frozen_string_literal: true

module MediaDownloader
  class MediaWrapper

    # ラップするメディアが含まれているツイート
    #
    # @return [Twitter::Tweet]
    attr_reader :tweet

    # ラップするメディア
    #
    # @return [Twitter::Media]
    attr_reader :media

    # メディアのインデックス番号
    #
    # @return [Integer]
    attr_reader :index

    # @param [Twitter::Tweet] tweet メディアが添付されているツイート
    # @param [Twitter::Media] media
    # @param [Integer] index media配列のインデックス. プログラム上でのインデックスなので一番最初の場合,0
    def initialize(tweet, media, index)
      @tweet = tweet
      @media = media
      @index = index
    end

    # メディアが写真かどうかの確認
    #
    # @return [Boolean]
    def photo?
      @media.is_a?(Twitter::Media::Photo)
    end

    # メディアがビデオかどうかの確認
    #
    # @return [Boolean]
    def video?
      @media.is_a?(Twitter::Media::Video)
    end

    # 表示上でのインデックス
    #
    # @return [Integer]
    def display_index
      index + 1
    end
  end
end
