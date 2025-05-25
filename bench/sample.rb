# frozen_string_literal: true

require_relative 'run_bench'

require_relative '../app/sample'

targets = {
  'match?' => -> { Sample.new.match? },
  'end_with?' => -> { Sample.new.end_with? }
}

RunBench.execute(targets)
