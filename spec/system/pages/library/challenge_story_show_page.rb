# frozen_string_literal: true

class Library::ChallengeStoryShowPage < BasePage
  set_url "/challenge_stories/{id}"

  element :story_title, "h1"
  element :description, "p"
  element :join_button, "#join_challenge", text: "Join Challenge"
  element :edit_link, 'a[href*="edit"]'
  element :delete_button, 'button[data-turbo-method="delete"]'
  elements :participants, ".participant"

  load_validation { has_story_title? }

  class << self
    def default_params
      {id: nil}
    end
  end

  def joined?
    !has_join_button?
  end
end
