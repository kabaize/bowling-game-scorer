class ScoresController < ApplicationController
  rescue_from ArgumentError, with: :render_bad_request

  def create
    rolls = params.require(:rolls)

    scorer = ScoreKeeper.new
    frames = scorer.frame_scores(rolls)
    total  = scorer.total_score(rolls)

    render json: {
      frames: frames,
      total: total
    }
  end

  private

  def render_bad_request(error)
    render json: { error: error.message }, status: :bad_request
  end
end
