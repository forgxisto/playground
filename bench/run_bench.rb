# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark/ips'
require 'benchmark-memory'

module RunBench
  def self.execute(targets = {})
    puts '##########################################################################'
    puts ''
    ips(targets)

    puts '##########################################################################'
    puts ''
    memory(targets)
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
