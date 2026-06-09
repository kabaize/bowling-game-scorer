# frozen_string_literal: true

# Bowling Score Calculator – WeInfuse Coding Exercise
# Implemented by: Keith Baize

# Calculates bowling scores frame by frame, taking rolls as input.
class ScoreKeeper
  def frame_scores(rolls)
    return [] if rolls.empty?

    validate_rolls!(rolls)

    pins = to_pins(rolls)

    frames = []
    roll_index = 0

    while frames.size < 10 && roll_index < rolls.length
      if strike?(rolls[roll_index])
        frames << score_strike_frame(roll_index, pins, rolls)
        roll_index += 1
      else
        frames << score_non_strike_frame(roll_index, pins, rolls)
        roll_index += 2
      end
    end

    frames
  end

  def total_score(rolls)
    frames = frame_scores(rolls)
    return nil if frames.any?(&:nil?)

    frames.sum
  end

  private

  def to_pins(rolls)
    pins = []

    rolls.each_with_index do |roll, i|
      pins << if roll == 'X'
                10
              elsif roll == '/'
                (10 - pins[i - 1])
              else
                roll.to_i
              end
    end

    pins
  end

  # -----------------------------
  # Detect special rolls
  # -----------------------------
  def strike?(roll)
    roll == 'X'
  end

  def spare?(roll)
    roll == '/'
  end

  # -----------------------------
  # Calculate frame score
  # -----------------------------
  def score_non_strike_frame(roll_index, pins, rolls)
    first_index = roll_index
    second_index = roll_index + 1

    return nil if second_index >= pins.length

    if spare?(rolls[second_index])
      bonus_index = second_index + 1

      return nil if bonus_index >= pins.length

      10 + pins[bonus_index]
    else
      first_pin = pins[first_index]
      second_pin = pins[second_index]

      first_pin + second_pin
    end
  end

  def score_strike_frame(roll_index, pins, _rolls)
    bonus_first_index = roll_index + 1
    bonus_second_index = roll_index + 2

    return nil if bonus_second_index >= pins.length

    10 + pins[bonus_first_index] + pins[bonus_second_index]
  end

  # -----------------------------
  # Other helpers
  # -----------------------------
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def validate_rolls!(rolls)
    rolls.each_with_index do |roll, index|
      valid = roll == 'X' ||
              roll == '/' ||
              (roll.is_a?(Integer) && roll.between?(0, 9))

      raise ArgumentError, "Invalid roll: #{roll}" unless valid

      next unless roll == '/'
      raise ArgumentError, "Spare cannot be the first roll of a frame: #{rolls}" if index.zero?

      previous = rolls[index - 1]
      raise ArgumentError, 'Spare must follow a numeric roll' if ['X', '/'].include?(previous)
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
