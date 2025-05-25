# frozen_string_literal: true

class Sample
  def match?
    '🐶🐱🐰'.match?(/🐰\z/)
  end

  def end_with?
    '🐶🐱🐰'.end_with?('🐰')
  end
end
