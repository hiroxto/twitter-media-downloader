# frozen_string_literal: true

module MediaDownloader
  class IDParser

    ID_DELIMITER = ':'
    TARGET_DELIMITER = ','
    VALID_ID_PATTERN = /^[1-9][0-9]{2,}/.freeze
    VALID_TARGETS = (0..4).map(&:to_s).freeze

    # @return [String]
    attr_reader :raw_data

    # @param [String] raw_data パースするID
    def initialize(raw_data)
      @raw_data = raw_data
    end

    # パースを行う
    #
    # @return [Array]
    #   0番目 : String ID
    #   1番目 : Array<Integer> ターゲット番号が含まれた配列
    def parse
      id, raw_target = split_id
      raise_invalid_id unless valid_id?(id)

      raw_target.nil? ? [id] : [id, split_target(raw_target)]
    end

    private

    # 生のデータを分割
    #
    # @return [Array<String>]
    def split_id
      @raw_data.split(ID_DELIMITER)
    end

    # ターゲットを分割し, 整数へ変換
    #
    # @param [String] raw_target
    # @return [Array<Integer>]
    def split_target(raw_target)
      targets = raw_target.split(TARGET_DELIMITER)
      raise_invalid_targets unless all_valid_targets?(targets)

      targets.map(&:to_i)
    end

    # IDが正しいかの判断を行う
    #
    # @param [String] id
    # @return [Boolean]
    def valid_id?(id)
      id.match(VALID_ID_PATTERN) != nil
    end

    # ターゲットの配列が全て正しいかの判断を行う
    #
    # @param [Array<String>]
    # @return [Boolean]
    def all_valid_targets?(targets)
      targets.all? { |target| valid_target?(target) }
    end

    # ターゲットが正しいかの判断を行う
    #
    # @param [String] target
    # @return [Boolean]
    def valid_target?(target)
      VALID_TARGETS.include?(target)
    end

    # 例外を投げるだけ
    def raise_invalid_id
      raise "Invalided id in #{@raw_data}"
    end

    # 例外を投げるだけ
    def raise_invalid_targets
      raise "Invalided targets #{@raw_data}"
    end
  end
end
