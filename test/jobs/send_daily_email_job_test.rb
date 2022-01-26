require "test_helper"

# bundle exec ruby -Itest test/jobs/send_daily_email_job_test.rb
class SendDailyEmailJobTest < ActiveJob::TestCase
  before do
    @test_job = mock
    @test_job.stubs(:deliver_later)

    for_each_user do |user_id|
      UserMailer.expects(:daily_email)
        .with(email_id: emails(:ready_to_send).id, user_id: user_id)
        .returns(@test_job)
    end
  end

  test "does not equeue draft emails" do
    for_each_user do |user_id|
      UserMailer.expects(:daily_email)
        .with(email_id: emails(:draft).id, user_id: user_id)
        .never
    end

    SendDailyEmailJob.perform_now
  end

  test "does not enqueue future emails" do
    for_each_user do |user_id|
      UserMailer.expects(:daily_email)
        .with(email_id: emails(:future).id, user_id: user_id)
        .never
    end

    SendDailyEmailJob.perform_now
  end

  test "enqueues emails ready for delivery" do
    @test_job.expects(:deliver_later).times(2)
    SendDailyEmailJob.perform_now
  end

  def for_each_user
    User.all.pluck(:id).each do |user_id|
      yield(user_id)
    end
  end
end
