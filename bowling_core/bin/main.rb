# frozen_string_literal: true

# Bowling Score Calculator – WeInfuse Coding Exercise
# Implemented by: Keith Baize

require_relative '../lib/score_keeper'

enable_total_score = false # Set to true to display total score
ROLLS = ['X', 7, '/', 9, 0, 'X', 0, 8, 8, '/', 0, 6, 'X', 'X', 'X', 8, 1].freeze

scorer = ScoreKeeper.new
frames = scorer.frame_scores(ROLLS)
puts "Frame Scores: #{frames}"

if enable_total_score
  total = scorer.total_score(ROLLS)
  puts "Total Score: #{total}"
end
