# frozen_string_literal: true

#
# ベンチマーク実行ヘルパー
#
# 使い方:
#   # 複数回実行して統計を取る（デフォルト）
#   Temp::RunBench.execute({
#     'メソッドA' => -> { some_method_a },
#     'メソッドB' => -> { some_method_b }
#   })
#
#   # 1回だけ実行（大量データ処理など、複数回実行できない場合）
#   # 時間とメモリを同時に計測（処理は1回のみ実行）
#   Temp::RunBench.execute({
#     'スクリプトA' => -> { heavy_script_a },
#     'スクリプトB' => -> { heavy_script_b }
#   }, mode: :single)
#

require 'benchmark/ips'
require 'benchmark-memory'

module Temp
  module RunBench
    # @param targets [Hash] ベンチマーク対象のハッシュ { name: -> { code } }
    # @param mode [Symbol] :ips (複数回実行), :single (1回のみ実行)
    def self.execute(targets = {}, mode: :ips)
      # ベンチマーク実行中はログを無効化
      silence_logs do
        print_header(targets, mode)

        if mode == :single
          print_section_header('⚡ 実行時間 & メモリ使用量計測 (1回のみ実行)')
          single_run_with_memory(targets)
        else
          print_section_header('⚡ 実行速度ベンチマーク (IPS: Iterations Per Second)')
          ips(targets)

          print_section_header('💾 メモリ使用量ベンチマーク')
          memory(targets)
        end

        print_footer(mode)
      end
    end

    def self.print_header(targets, mode)
      puts ''
      puts '=' * 80
      puts '🔬 ベンチマーク実行開始'
      puts '=' * 80
      puts ''
      puts "📋 対象: #{targets.keys.join(', ')}"
      puts "📊 項目数: #{targets.size}"
      puts "🔧 モード: #{mode == :single ? '1回のみ実行' : '複数回実行 (統計)'}"
      puts ''
    end

    def self.print_section_header(title)
      puts ''
      puts '-' * 80
      puts title
      puts '-' * 80
      puts ''
    end

    def self.print_footer(mode)
      puts ''
      puts '=' * 80
      puts '✅ ベンチマーク完了'
      puts '=' * 80
      puts ''
      puts '📖 結果の見方:'
      if mode == :single
        puts '  - user: ユーザーCPU時間'
        puts '  - system: システムCPU時間'
        puts '  - total: user + system'
        puts '  - real: 実際の経過時間（これが重要）'
        puts '  - Memory: ヒープメモリ使用量（小さいほど省メモリ）'
        puts '  - Objects: 生成されたオブジェクト数'
        puts ''
        puts '💡 注意: メモリ計測は GC の影響を受けるため、参考値としてご利用ください'
      else
        puts '  - IPS: 1秒あたりの実行回数（大きいほど高速）'
        puts '  - comparison: 最速を1.00xとした相対速度'
        puts '  - Memory: 使用メモリ量（小さいほど省メモリ）'
      end
      puts ''
    end

    def self.silence_logs
      old_logger = ActiveRecord::Base.logger
      old_level = Rails.logger.level

      begin
        ActiveRecord::Base.logger = nil
        Rails.logger.level = Logger::ERROR

        yield
      ensure
        # 元の設定に戻す
        ActiveRecord::Base.logger = old_logger
        Rails.logger.level = old_level
      end
    end

    def self.single_run_with_memory(targets = {})
      results = []
      max_name_length = targets.keys.map(&:to_s).map(&:length).max

      targets.each do |name, method|
        # GCを実行してメモリ状態をクリーンに
        GC.start

        # 実行前のメモリ状態を記録
        before_stat = GC.stat
        before_objects = ObjectSpace.count_objects

        # 時間とメモリを計測しながら実行
        time_result = Benchmark.measure { method.call }

        # 実行後のメモリ状態を記録
        after_stat = GC.stat
        after_objects = ObjectSpace.count_objects

        # メモリ使用量を計算（バイト単位）
        # heap_allocated_pages の増加 × ページサイズ
        memory_allocated = (after_stat[:heap_allocated_pages] - before_stat[:heap_allocated_pages]) * 16384 # 16KB per page
        # オブジェクト数の増加
        objects_allocated = after_objects[:TOTAL] - before_objects[:TOTAL]

        results << {
          name:,
          time: time_result,
          memory_bytes: memory_allocated,
          objects: objects_allocated
        }

        formatted_name = name.to_s.ljust(max_name_length)
        memory_mb = memory_allocated / 1024.0 / 1024.0
        puts ''
        puts "#{formatted_name}  #{time_result}  Memory: #{format('%.2f', memory_mb)} MB  Objects: #{objects_allocated}"
      end

      # 時間での比較を表示
      puts ''
      puts '📊 実行時間の比較:'
      fastest_time = results.min_by { |r| r[:time].real }
      results.sort_by { |r| r[:time].real }.each_with_index do |r, idx|
        ratio = r[:time].real / fastest_time[:time].real
        comparison = idx.zero? ? '← 最速' : format('%.2fx slower', ratio)
        formatted_name = r[:name].to_s.ljust(max_name_length)
        puts "  #{formatted_name}  #{format('%8.2f', r[:time].real)}秒  #{comparison}"
      end

      # メモリでの比較を表示
      puts ''
      puts '💾 メモリ使用量の比較:'
      results.sort_by { |r| r[:memory_bytes] }.each_with_index do |r, idx|
        memory_mb = r[:memory_bytes] / 1024.0 / 1024.0
        comparison = idx.zero? ? '← 最小' : ''
        formatted_name = r[:name].to_s.ljust(max_name_length)
        puts "  #{formatted_name}  #{format('%10.2f', memory_mb)} MB  (#{r[:objects]} objects)  #{comparison}"
      end
    end

    def self.ips(targets = {})
      Benchmark.ips do |x|
        targets.each do |name, method|
          x.report(name) { method.call }
        end

        x.compare!
      end
    end

    def self.memory(targets = {})
      Benchmark.memory do |x|
        targets.each do |name, method|
          x.report(name) { method.call }
        end

        x.compare!
      end
    end
  end
end
