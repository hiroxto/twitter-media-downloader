# frozen_string_literal: true

require File.expand_path('error/option_number_validator_error.rb', __dir__)

module MediaDownloader
  class OptionNumberValidator

    # @param [Twitter::Tweet] tweet
    # @param [Array<Integer>] numbers
    def initialize(tweet, numbers)
      @tweet = tweet
      @medias = @tweet.media
      @numbers = numbers
    end

    # バリデーションを行う
    def validate
      empty_array?
      over_medias_size?
      all_exist_number?
    end

    private

    # 空の配列かの確認を行う
    def empty_array?
      raise MediaDownloader::Error::OptionNumberValidatorError, '番号が空です' if @numbers.empty?
    end

    # 番号の最大値が, メディア数を超えていないかの確認を行う
    def over_medias_size?
      raise MediaDownloader::Error::OptionNumberValidatorError, '番号の最大値がメディアの数より多いです' if @numbers.max > @medias.size
    end

    # 全ての番号が存在するかの確認を行う
    def all_exist_number?
      @numbers.each do |number|
        raise MediaDownloader::Error::OptionNumberValidatorError, "#{number}番目のメディアは存在しません" if @medias[number - 1].nil?
      end
    end
  end
end
