# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Scores API", type: :request do
  describe "POST /score" do
    it "returns frame scores and total for a valid complete game" do
      rolls = ["X", 7, "/", 9, 0, "X", 0, 8, 8, "/", 0, 6, "X", "X", "X", 8, 1]

      post "/score", params: { rolls: rolls }, as: :json

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["total"]).to eq(167)

      expect(body["frames"]).to be_an(Array)
      expect(body["frames"].size).to eq(10)
    end

    it "returns 400 when rolls are invalid" do
      rolls = ["A"]

      post "/score", params: { rolls: rolls }, as: :json

      expect(response).to have_http_status(:bad_request)

      body = JSON.parse(response.body)
      expect(body["error"]).to be_a(String)
    end

    it "returns total as nil for an incomplete game" do
      rolls = ["X"]

      post "/score", params: { rolls: rolls }, as: :json

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["total"]).to be_nil
      expect(body["frames"]).to eq([nil])
    end
  end
end
