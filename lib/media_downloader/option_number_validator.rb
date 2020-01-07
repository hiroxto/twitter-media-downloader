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

    def validate
      empty_array?
      over_medias_size?
    end

    private

    def empty_array?
      raise '番号が空です' if @numbers.empty?
    end

    def over_medias_size?
      raise '番号の最大値がメディアの数より多いです' if @numbers.max >= @medias.size
    end

  end
end
