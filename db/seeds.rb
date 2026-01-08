# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

puts "\n📊 Current State:"
puts "  Users: #{User.count}"
puts "  Challenge Stories: #{ChallengeStory.count}"
puts "  Challenge Participants: #{ChallengeParticipant.count}"
puts "  Check-ins: #{ChallengeCheckIn.count}"
puts "  Check-in Likes: #{ChallengeCheckInLike.count}"
puts "  Rewards: #{ChallengeReward.count}"
puts "  Story Likes: #{ChallengeStoryLike.count}"

# Clean up existing demo data
puts "🧹 Cleaning up existing demo data..."

demo_user_params = {
  "00000000-0001-4000-8000-000000000000" => {username: "AliceWonderland"},
  "00000000-0002-4000-8000-000000000000" => {username: "BobBuilder"},
  "00000000-0003-4000-8000-000000000000" => {username: "CharlieChocolate"},
  "00000000-0004-4000-8000-000000000000" => {username: "DoraExplorer"}
}
demo_user_ids = demo_user_params.keys

# Find all challenge stories that have any participants from demo users
demo_challenge_story_ids = ChallengeParticipant
  .where(user_id: demo_user_ids)
  .pluck(:challenge_story_id)
  .uniq

# Destroy each challenge story individually to trigger callbacks and dependent destroys
ChallengeStory.where(id: demo_challenge_story_ids).find_each(&:destroy)

# Destroy demo users individually to trigger callbacks and dependent destroys
User.where(id: demo_user_ids).find_each(&:destroy)

puts "✅ Cleanup complete"

# Create demo users with consistent UUIDs

users = {}
demo_user_params.each do |uuid, attrs|
  user = User.create!(attrs)
  user.update_column(:id, uuid)
  users[attrs[:username]] = user
end

alice = users["AliceWonderland"]
bob = users["BobBuilder"]
charlie = users["CharlieChocolate"]
dora = users["DoraExplorer"]

puts "✅ there are now #{User.count} users"

# User mapping for dynamic lookup
user_map = {
  alice: alice,
  bob: bob,
  charlie: charlie,
  dora: dora
}

# Challenge configurations
challenge_data = {
  "00000000-0000-4000-8000-000000000001" => {
    title: "30-Day Gym Challenge(DEMO)",
    description: "Hit the gym every day for 30 days! Build strength, endurance, and healthy habits together. 💪",
    start_offset: -5,
    finish_offset: 25,
    completed: false,
    participants: [alice, bob, charlie],
    check_ins: {
      alice: [
        "Day 1: Gym session complete! 💪",
        "Day 2: Feeling stronger already! 🏋️‍♀️",
        "Day 3: Leg day was tough but worth it! 🦵"
      ],
      bob: [
        "First workout! 🚀",
        "Leg day! 🏋️‍♂️",
        "PR today! 🎯",
        "Bench press 💪",
        "Morning grind 🌅"
      ],
      charlie: [
        "Day 1: Finally made it! 😅",
        "another day Squats and lunges 🦵",
        "Strong week! 💪"
      ]
    },
    rewards: [
      {giver: bob, receiver: alice, description: "I'll buy you a protein smoothie if you don't miss a single day! 🥤", status: :pending},
      {giver: alice, receiver: charlie, description: "Complete 20 days and I'll get you those gym gloves you wanted! 🧤", status: :pending}
    ]
  },
  "00000000-0000-4000-8000-000000000002" => {
    title: "Read Books Challenge(DEMO)",
    description: "Expand your mind by reading 10 books in 2 months. Share insights and recommendations! 📚",
    start_offset: -25,
    finish_offset: -5,
    completed: true,
    participants: [alice, bob, dora],
    check_ins: {
      alice: [
        "Book 1: 'Atomic Habits' 📖",
        "Still going strong habits!",
        "Started 'Sapiens' - fascinating read! 🧠",
        "Halfway through 'Sapiens' 🤯",
        "Book 3: 'The Midnight Library' 🌙"
      ],
      dora: [
        "'Where the Crawdads Sing' 🦋",
        "'The Silent Patient' 😱"
      ],
      bob: [
        "Started '1984'",
        "'The Alchemist' 🌟"
      ]
    },
    rewards: [
      {giver: alice, receiver: dora, description: "Finish all 10 books and I'll buy you that Kindle! 📱", status: :fulfilled},
      {giver: dora, receiver: alice, description: "I'll recommend my top 5 books! 📚", status: :fulfilled}
    ]
  },
  "00000000-0000-4000-8000-000000000003" => {
    title: "21-Day Meditation & Mindfulness(DEMO)",
    description: "Find inner peace through daily meditation. Even 5 minutes counts! 🧘‍♂️✨",
    start_offset: -2,
    finish_offset: 23,
    completed: false,
    participants: [bob, charlie, dora],
    check_ins: {
      bob: [
        "Started with 5 minutes of breathing. Feeling calm! 🧘‍♂️",
        "Tried guided meditation. Slept better! 😴",
        "Meditated outdoors. Birds were a nice touch. 🐦"
      ],
      charlie: [
        "Day 1: Mind kept wandering, but I stuck with it. 🌱",
        "Day 2: Used a meditation app. Helped a lot! 📱",
        "Day 3: Felt more focused at work today. 💼"
      ],
      dora: [
        "D1: Lit a candle and meditated. Peaceful! 🕯️",
        "D2: Shared my playlist with the group. 🎵",
        "D3: Did a body scan meditation. Relaxed! 😌"
      ]
    },
    rewards: [
      {giver: bob, receiver: charlie, description: "Complete all 21 days and I'll treat you to a spa day! 🧖‍♂️", status: :pending},
      {giver: dora, receiver: bob, description: "I'll share my secret meditation playlist! 🎵", status: :pending},
      {giver: charlie, receiver: dora, description: "Perfect attendance = herbal tea collection! 🍵", status: :pending}
    ]
  }
}

# Create or update challenges
challenge_data.each do |id, data|
  challenge = ChallengeStory.find_or_initialize_by(id: id)
  challenge.assign_attributes(
    title: data[:title],
    description: data[:description],
    start: data[:start_offset].days.from_now.to_date,
    finish: data[:finish_offset].days.from_now.to_date,
    completed: data[:completed]
  )
  challenge.save!
  challenge.update_column(:id, id) if challenge.id != id

  # Create participants
  data[:participants]&.each do |user|
    ChallengeParticipant.find_or_create_by!(
      challenge_story: challenge,
      user: user
    ) { |p| p.status = :active }
  end

  # Create check-ins for any challenge with :check_ins
  data[:check_ins]&.each do |user_key, messages|
    user = user_map[user_key]
    participant = challenge.challenge_participants.find_by(user: user)
    next unless participant
    messages.reverse.each_with_index do |message, idx|
      next unless message
      challenge.challenge_check_ins.find_or_create_by!(
        challenge_participant: participant,
        created_at: (idx + 1).days.ago.beginning_of_day
      ) { |c| c.message = message }
    end
  end

  # Add some likes to check-ins
  if challenge.challenge_check_ins.any?
    challenge.challenge_check_ins.limit(10).each do |checkin|
      data[:participants].each do |liker|
        next if checkin.challenge_participant.user == liker
        if rand < 0.6
          ChallengeCheckInLike.find_or_create_by!(
            challenge_check_in: checkin,
            user: liker
          )
        end
      end
    end
  end

  # Create rewards
  data[:rewards]&.each do |reward_data|
    ChallengeReward.find_or_create_by!(
      challenge_story: challenge,
      giver: challenge.challenge_participants.find_by(user: reward_data[:giver]),
      receiver: challenge.challenge_participants.find_by(user: reward_data[:receiver])
    ) do |reward|
      reward.description = reward_data[:description]
      reward.status = reward_data[:status]
    end
  end

  # Add some story likes
  sample_liker = data[:participants].sample
  ChallengeStoryLike.find_or_create_by!(challenge_story: challenge, user: sample_liker) if sample_liker

  puts "✅ Created/updated '#{challenge.title}' with #{challenge.challenge_check_ins.count} check-ins, #{challenge.challenge_rewards.count} rewards"
end

puts "\n📊 Summary:"
puts "  Users: #{User.count}"
puts "  Challenge Stories: #{ChallengeStory.count}"
puts "  Challenge Participants: #{ChallengeParticipant.count}"
puts "  Check-ins: #{ChallengeCheckIn.count}"
puts "  Check-in Likes: #{ChallengeCheckInLike.count}"
puts "  Rewards: #{ChallengeReward.count}"
puts "  Story Likes: #{ChallengeStoryLike.count}"

puts "\n🎉 Seeding complete!"
