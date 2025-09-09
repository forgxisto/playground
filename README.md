# Ruby Playground

Ruby のコード実験用プレイグラウンドです。小さなサンプル、RSpec によるテスト、簡単なベンチマーク（IPS/メモリ）と Docker 開発環境を含みます。

## 概要

- サンプル: `app/sample.rb`（絵文字を含む文字列の末尾判定の比較）
- ベンチ: `bench/`（`benchmark-ips` と `benchmark-memory`）
- テスト: `spec/`（RSpec）
- ツール: RuboCop、debug など（必要に応じて）

## 必要要件

- Ruby 3.4 以降（任意の 3.x でも概ね可）
- Bundler

## セットアップ

```bash
bundle install
```

## サンプルの使い方

`Sample` クラスは文字列の末尾チェックを 2 通りで比較します。

- 実行例（IRB で確認）:

```bash
irb -r ./app/sample.rb
>> Sample.new.match?
=> true
>> Sample.new.end_with?
=> true
```

## ベンチマーク

末尾判定（`match?` vs `end_with?`）の速度/メモリを測定します。

```bash
bundle exec ruby bench/sample.rb
```

独自のターゲットを追加する場合は `bench/sample.rb` を参考に、`targets` にラベルと Proc を追加してください。共通ロジックは `bench/run_bench.rb` にあります。

## テスト

RSpec を使ったサンプルテストが `spec/` にあります。

```bash
bundle exec rspec
```

## Lint/静的解析（任意）

RuboCop を導入済みです（設定ファイルは任意）。

```bash
bundle exec rubocop
```

## Docker を使う

ローカルに Ruby を入れたくない場合は Docker で実行できます。

```bash
# ビルド（Ruby バージョンは任意に上書き可能）
docker build -t ruby-playground . --build-arg RUBY_VERSION=3.4.2

# 起動（カレントをマウントして作業）
docker run -it --rm -v "$(pwd)":/app -w /app ruby-playground bash

# コンテナ内で依存を入れて実行
bundle install
bundle exec rspec
bundle exec ruby bench/sample.rb
```

## ディレクトリ構成

```
Gemfile             # 依存定義（benchmark-ips, benchmark-memory, rspec, rubocop など）
app/
  sample.rb         # 末尾判定のサンプル実装
bench/
  run_bench.rb      # ベンチマーク共通実行ヘルパー（IPS/メモリ）
  sample.rb         # ベンチマークのエントリ
spec/
  spec_helper.rb    # RSpec 初期化
  sample_spec.rb    # サンプルテスト
Dockerfile          # 開発用 Docker イメージ
```

## メモ

- `match?(/…\z/)` と `end_with?` の違いを題材に、表現の明確さや速度/メモリの差を比較できます。
- ベンチやテストを追加して、気軽に Ruby の振る舞いを検証してください。

