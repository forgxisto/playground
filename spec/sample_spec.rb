# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Sample' do
  it 'adds two numbers' do
    expect(1 + 2).to eq(3)
  end

  it 'subtracts two numbers' do
    expect(5 - 2).to eq(3)
  end

  it 'multiplies two numbers' do
    expect(2 * 3).to eq(6)
  end

  it 'divides two numbers' do
    expect(6 / 2).to eq(3)
  end
end
