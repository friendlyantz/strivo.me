require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "when not signed in" do
      it "returns the home page" do
        get root_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in with active participation" do
      let(:user) { create(:user) }
      let(:story) { create(:challenge_story) }
      let!(:participant) { create(:challenge_participant, user: user, challenge_story: story) }

      before { sign_in_as(user) }

      it "renders home page" do
        get root_path

        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in without active participation" do
      let(:user) { create(:user) }

      before { sign_in_as(user) }

      it "renders home page" do
        get root_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
