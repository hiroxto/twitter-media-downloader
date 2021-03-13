# twitter-media-downloader

Twitterの画像,動画などをダウンロードするツール

`ruby downloader.rb id:number`

全数ダウンロード

`12345:0`

番号指定

`12345:1 12345:1,3`

使用できる環境変数

|環境変数|説明|例|
|:---:|:---:|:---:|
|`SAVE_FOLDER`|ダウンロード先のフォルダ名|`SAVE_FOLDER=test ruby downloader.rb id`|
|`TARGET_ALL`|標準で全数ダウンロード。セットされた上で番号オプションがあると番号オプションが優先される|`TARGET_ALL=true ruby downloader.rb id`|

## Dockerを使用する

Dockerでも使えるようになっている

`docker-compose-custom.yml`に保存先のボリュームや環境変数を設定する

```yaml
version: '3'

services:
  app:
    volumes:
      - /path/to/save:/save-base-dir:cached
    environment:
      SAVE_FOLDER: all
```

実行する際には環境変数に`COMPOSE_FILE`でファイルを指定する．

```bash
COMPOSE_FILE=docker-compose.yml:docker-compose-custom.yml docker-compose run --rm app ruby downloader.rb 1234
```

## License

MIT License