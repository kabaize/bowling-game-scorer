# frozen_string_literal: true

# Bowling Score Calculator – WeInfuse Coding Exercise
# Implemented by: Keith Baize

require 'spec_helper'
require_relative '../lib/score_keeper'

RSpec.describe ScoreKeeper do
  # -----------------------------
  # Calculate total score
  # -----------------------------
  describe '#total_score' do
    it 'scores a complete game' do
      scorer = ScoreKeeper.new
      rolls = ['X', 7, '/', 9, 0, 'X', 0, 8, 8, '/', 0, 6, 'X', 'X', 'X', 8, 1]
      result = scorer.total_score(rolls)

      expect(result).to eq(167)
    end

    it 'scores an incomplete game' do
      scorer = ScoreKeeper.new
      rolls = ['X']
      result = scorer.total_score(rolls)

      expect(result).to be_nil
    end

    it 'scores an all-strikes game' do
      scorer = ScoreKeeper.new
      rolls = ['X'] * 12
      result = scorer.total_score(rolls)

      expect(result).to eq(300)
    end

    it 'scores an all-spares game' do
      scorer = ScoreKeeper.new
      rolls = ([5, '/'] * 10) + [5]
      result = scorer.total_score(rolls)

      expect(result).to eq(150)
    end

    it 'scores an all-zeros game' do
      scorer = ScoreKeeper.new
      rolls = [0] * (2 * 10)
      result = scorer.total_score(rolls)

      expect(result).to eq(0)
    end
  end

  # -----------------------------
  # Score individual frames
  # -----------------------------
  describe '#frame_scores' do
    # -----------------------------
    # WeInfuse example inputs
    # ---------------------------
    it 'scores the first WeInfuse example' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores([4, 5, 'X', 8])

      expect(result).to eq([9, nil, nil])
    end

    it 'scores the second WeInfuse example' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores([4, 5, 'X', 8, 1])

      expect(result).to eq([9, 19, 9])
    end

    it 'scores a spare followed by an open frame' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores([7, '/', 3, 4])

      expect(result).to eq([13, 7])
    end

    it 'scores consecutive strikes correctly' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores(['X', 'X', 3, 4])

      expect(result).to eq([23, 17, 7])
    end

    it 'scores a 10th-frame spare correctly with one bonus roll' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, '/', 5])

      expect(result).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 15])
    end

    it 'scores a 10th-frame strike with two bonus strikes' do
      scorer = ScoreKeeper.new
      rolls = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'X', 'X', 'X']
      result = scorer.frame_scores(rolls)

      expect(result).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 30])
    end

    it 'scores a single incomplete open frame' do
      scorer = ScoreKeeper.new
      result = scorer.frame_scores([4])

      expect(result).to eq([nil])
    end

    it 'raises an error when an invalid roll is provided' do
      scorer = ScoreKeeper.new

      expect { scorer.frame_scores([11]) }.to raise_error(ArgumentError)
      expect { scorer.frame_scores(['A']) }.to raise_error(ArgumentError)
    end

    it 'raises an error when a spare appears as first roll' do
      scorer = ScoreKeeper.new
      rolls = ['/']

      expect { scorer.frame_scores(rolls) }.to raise_error(ArgumentError)
    end
  end
end
