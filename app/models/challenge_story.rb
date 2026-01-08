# frozen_string_literal: true

class ChallengeStory < ApplicationRecord
  MAX_PARTICIPANTS = 4

  # Associations
  has_many :challenge_check_ins, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :challenge_participants, dependent: :destroy
  has_many :challenge_rewards, dependent: :destroy
  has_many :challenge_story_likes, dependent: :destroy
  has_many :active_participants, -> { active }, class_name: "ChallengeParticipant"
  has_many :liking_users, through: :challenge_story_likes, source: :user

  # Broadcasts (after associations)
  broadcasts

  # Validations
  validates :title, presence: true
  validates :description, presence: true, length: {maximum: 500}
  validates :start, :finish, presence: true
  validate :finish_cannot_be_earlier_than_start

  # Scopes
  scope :active, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }

  # Public methods
  def finished?
    finish < Time.zone.today
  end

  def latest_photo_check_in
    challenge_check_ins.joins(:photo_attachment).first
  end

  def liked_by?(user)
    return false unless user
    challenge_story_likes.exists?(user: user)
  end

  def at_capacity?
    active_participants.count >= MAX_PARTICIPANTS
  end

  def available_spots
    MAX_PARTICIPANTS - active_participants.count
  end

  def mark_complete!
    update!(completed: true)
  end

  def find_or_activate_participant!(user)
    participant = challenge_participants.find_by(user: user)

    if participant
      participant.update!(status: :active) if participant.inactive?
      participant
    else
      challenge_participants.create!(user: user, status: :active)
    end
  end

  private

  def finish_cannot_be_earlier_than_start
    if finish.present? && start.present? && finish < start
      errors.add(:finish, "cannot be earlier than the start date")
    end
  end
end
