core_path = Rails.root.join("..", "bowling_core", "lib", "score_keeper.rb")

unless File.exist?(core_path)
  raise "Expected core ScoreKeeper file at #{core_path}, but it was not found."
end

require core_path