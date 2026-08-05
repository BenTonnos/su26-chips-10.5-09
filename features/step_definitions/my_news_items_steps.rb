# frozen_string_literal: true

Given('a representative exists') do
  @representative = Representative.create!(name: 'Test Representative')
end

Given("I visit a representative's news items page") do
  visit '/representatives/1/news_items'
end

When('I select a representative') do
  @selected_representative = Representative.where.not(name: nil).first

  select(
    @selected_representative.name,
    from: 'news_item_representative_id'
  )
end

When('I select an issue') do
  @selected_issue = NewsItem.issues.first

  select(
    @selected_issue,
    from: 'news_item_issue'
  )
end

Then('I should see the selected representative link') do
  page.should have_link(@selected_representative.name)
end

Then('I should see the selected issue') do
  page.should have_content(@selected_issue)
end
