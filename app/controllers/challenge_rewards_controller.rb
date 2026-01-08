class ChallengeRewardsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :require_current_user!, except: [:index]
  before_action :set_challenge_story
  before_action :set_reward, only: [:fulfill, :cancel]
  before_action :verify_receiver, only: [:fulfill]
  before_action :verify_giver, only: [:cancel]

  def index
    all_rewards = @challenge_story.challenge_rewards.includes(giver: :user, receiver: :user).to_a

    if current_user
      @current_challenge_participant = @challenge_story.challenge_participants.find_by(user: current_user)
      if @current_challenge_participant
        @rewards_received = all_rewards.select { |r| r.receiver_id == @current_challenge_participant.id }
        @rewards_given = all_rewards.select { |r| r.giver_id == @current_challenge_participant.id }
        my_reward_ids = (@rewards_received + @rewards_given).map(&:id)
        @rewards_others = all_rewards.reject { |r| my_reward_ids.include?(r.id) }
      else
        @rewards_received = []
        @rewards_given = []
        @rewards_others = all_rewards
      end
    else
      @rewards_received = []
      @rewards_given = []
      @rewards_others = all_rewards
    end
  end

  def new
    @reward = ChallengeReward.new(challenge_story: @challenge_story)
    @current_challenge_participant = current_challenge_participant_for_story
    @participants = available_participants_for_pledge
  end

  def create
    @reward = ChallengeReward.new(reward_params)
    @reward.challenge_story = @challenge_story

    if @reward.save
      redirect_to challenge_story_challenge_rewards_path(@challenge_story),
        notice: "You've successfully pledged a reward!"
    else
      @current_challenge_participant = current_challenge_participant_for_story
      @participants = available_participants_for_pledge
      render :new, status: :unprocessable_content
    end
  end

  def fulfill
    @reward.fulfill!
    redirect_to challenge_story_challenge_rewards_path(@challenge_story),
      notice: "Reward has been marked as fulfilled!"
  end

  def cancel
    @reward.cancel!
    redirect_to challenge_story_challenge_rewards_path(@challenge_story),
      notice: "Reward has been canceled."
  end

  private

  def set_challenge_story
    @challenge_story = ChallengeStory.find(params[:challenge_story_id])
  end

  def set_reward
    @reward = @challenge_story.challenge_rewards.find(params[:id])
  end

  def verify_giver
    return if @reward.giver.user == current_user

    redirect_to challenge_story_challenge_rewards_path(@challenge_story),
      alert: "You can only cancel rewards you've pledged."
  end

  def verify_receiver
    return if @reward.receiver.user == current_user

    redirect_to challenge_story_challenge_rewards_path(@challenge_story),
      alert: "You can only fulfill rewards pledged to you."
  end

  def reward_params
    params.require(:challenge_reward).permit(:giver_id, :receiver_id, :description)
  end

  def current_challenge_participant_for_story
    @challenge_story.active_participants.find_by(user: current_user)
  end

  def available_participants_for_pledge
    current_challenge_participant = current_challenge_participant_for_story
    return [] unless current_challenge_participant

    existing_receiver_ids = ChallengeReward.where(
      giver_id: current_challenge_participant.id,
      challenge_story_id: @challenge_story.id
    ).pluck(:receiver_id)

    @challenge_story.active_participants.where.not(id: existing_receiver_ids)
  end
end
