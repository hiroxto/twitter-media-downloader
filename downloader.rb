# frozen_string_literal: true

require 'bundler'
Bundler.require
require 'yaml'
require File.expand_path('./lib/media_downloader.rb')

config = YAML.load_file('./config.yml')

client = Twitter::REST::Client.new(config['twitter'])

ARGV.each do |tweet_id|
  downloader = MediaDownloader::Downloader.new(client, tweet_id, config['base_dir'])
  downloader.download
rescue MediaDownloader::Error::RuntimeError => e
  pp e
  sleep(10)
end
