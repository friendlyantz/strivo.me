class ChallengeStoriesController < ApplicationController
  before_action :set_challenge_story, only: %i[edit update destroy complete]
  before_action :require_current_user!, except: %i[show]

  def index
    return @challenge_stories = ChallengeStory.none unless current_user

    @challenge_stories = ChallengeStory
      .joins(:challenge_participants)
      .where(challenge_participants: {user_id: current_user.id, status: :active})
      .includes(:active_participants, challenge_check_ins: {photo_attachment: :blob})
      .left_joins(:challenge_check_ins)
      .group("challenge_stories.id")
      .order(Arel.sql("MAX(challenge_check_ins.created_at) DESC NULLS LAST, challenge_stories.updated_at DESC"))

    # Preload current user's participations to avoid N+1 in views
    story_ids = @challenge_stories.map(&:id)
    @user_participations = ChallengeParticipant
      .where(challenge_story_id: story_ids, user_id: current_user.id)
      .index_by(&:challenge_story_id)
  end

  def show
    @challenge_story = ChallengeStory
      .includes(
        challenge_participants: [:user, :challenge_check_ins],
        challenge_rewards: [:giver, :receiver],
        challenge_check_ins: [:challenge_participant, :challenge_check_in_likes, photo_attachment: :blob]
      )
      .find(params[:id])

    @participants = @challenge_story.challenge_participants
      .select(&:active?)
      .sort_by(&:created_at)

    if current_user
      @current_challenge_participant = @participants.find { |p| p.user_id == current_user.id }

      time_limit_till_next_check_in = 12.hours
      recent_check_in = @current_challenge_participant&.challenge_check_ins&.where(created_at: time_limit_till_next_check_in.ago..Time.zone.now)&.order(:created_at)&.last
      @time_of_a_next_check_in = if recent_check_in.present?
        recent_check_in.created_at + time_limit_till_next_check_in
      end

    end
  end

  def new
    @challenge_story = ChallengeStory.new(
      start: Time.zone.today,
      finish: Time.zone.today + 7.days
    )
  end

  def edit
  end

  def create
    @challenge_story = ChallengeStory.new(challenge_story_params)

    if @challenge_story.save
      @challenge_story.find_or_activate_participant!(current_user)
      redirect_to @challenge_story, notice: "Challenge story was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @challenge_story.update(challenge_story_params)
      redirect_to @challenge_story, notice: "Challenge story was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @challenge_story.destroy!
    redirect_to challenge_stories_path, status: :see_other, notice: "Challenge story was successfully destroyed."
  end

  def complete
    @challenge_story.mark_complete!
    redirect_to challenge_stories_path, notice: "Challenge marked as complete! Time to create a new one."
  end

  private

  def set_challenge_story
    @challenge_story = ChallengeStory.find(params.expect(:id))
  end

  def challenge_story_params
    params.expect(challenge_story: [:title, :description, :start, :finish])
  end
end
