# frozen_string_literal: true

class Library::NewChallengeStoryPage < BasePage
  set_url "/challenge_stories/new"

  element :title_field, 'input[name="challenge_story[title]"]'
  element :description_field, 'textarea[name="challenge_story[description]"]'
  element :start_field, 'input[name="challenge_story[start]"]'
  element :finish_field, 'input[name="challenge_story[finish]"]'
  element :submit_button, 'button[type="submit"]'

  def fill_form(title:, description:, start_date:, finish_date:)
    title_field.set(title)
    description_field.set(description)
    start_field.set(start_date.to_s)
    finish_field.set(finish_date.to_s)
  end

  def submit
    submit_button.click
  end
end
