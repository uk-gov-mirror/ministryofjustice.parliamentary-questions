require 'feature_helper'

feature 'Watch list member sees allocated questions', suspend_cleaner: true do
  # include Features::EmailHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    # clear_sent_mail
    @aos = ActionOfficer.where("email like 'ao%@pq.com'")
    @pq  = generate_dummy_pq(@aos)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'An admin can create a new watchlist member' do
    create_pq_session
    click_link 'Settings'
    click_link 'Watch list'
    click_link_or_button 'Add watchlist member'
    fill_in 'Name', with: 'test-member-a'
    fill_in 'Email', with: 'test-member-a@pq.com'
    click_link_or_button 'Save'

    expect(page).to have_text(/watchlist member was successfully created/i)
  end

  scenario 'An admin can trigger an email notification to the watchlist members with a link to the daily question list' do
    create_pq_session
    visit watchlist_members_path
    click_link_or_button 'Send allocation info'
    expect(page).to have_text('An email with the allocation information has been sent to all of the watchlist member')
    # expect(mail.cc).to include('test-member-a@pq.com')
    # expect(url).to_not be_blank
  end

  scenario 'A watchlist member follows an email link to view the list of daily questions' do
    token_db = Token.find_by(path: watchlist_dashboard_path)
    entity = token_db.entity
    token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

    visit watchlist_dashboard_url(token: token, entity: entity)

    expect(page).to have_text(/allocated today 1/i)
    expect(page).to have_text(@pq.question)
    allocation_el = find("*[data-pquin='#{@pq.uin}']")

    @aos.each do |action_officer|
      expect(allocation_el).to have_text(action_officer.name)
    end
  end

  scenario 'The URL token sent to the watchlist member expires after 24 hours' do
    WatchlistReportService.new(nil, DateTime.now - 2.days).notify_watchlist

    token_db = Token.find_by(path: watchlist_dashboard_path)
    entity = token_db.entity
    token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

    visit watchlist_dashboard_url(token: token, entity: entity)

    # url = extract_url_like(watchlist_dashboard_path, sent_mail.last)
    # visit url

    expect(page).to have_text(/Link expired/i)
  end

  private

  def generate_dummy_pq(aos)
    PQA::QuestionLoader.new.load_and_import

    q                   = Pq.first
    q.minister          = Minister.find_by(name: 'Chris Grayling')
    q.action_officers   = aos
    q.internal_deadline = Time.zone.today + 1.day
    q.internal_deadline = Time.zone.today + 2.days
    q.update_state!
    q
  end
end
