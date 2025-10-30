# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark/ips'
require 'benchmark-memory'

module RunBench
  def self.execute(targets = {})
    print_header(targets)

    print_section_header('⚡ 実行速度ベンチマーク (IPS: Iterations Per Second)')
    ips(targets)

    print_section_header('💾 メモリ使用量ベンチマーク')
    memory(targets)

    print_footer
  end

  def self.print_header(targets)
    puts ''
    puts '=' * 80
    puts '🔬 ベンチマーク実行開始'
    puts '=' * 80
    puts ''
    puts "📋 対象: #{targets.keys.join(', ')}"
    puts "📊 項目数: #{targets.size}"
    puts ''
  end

  def self.print_section_header(title)
    puts ''
    puts '-' * 80
    puts title
    puts '-' * 80
    puts ''
  end

  def self.print_footer
    puts ''
    puts '=' * 80
    puts '✅ ベンチマーク完了'
    puts '=' * 80
    puts ''
    puts '📖 結果の見方:'
    puts '  - IPS: 1秒あたりの実行回数（大きいほど高速）'
    puts '  - comparison: 最速を1.00xとした相対速度'
    puts '  - Memory: 使用メモリ量（小さいほど省メモリ）'
    puts ''
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
