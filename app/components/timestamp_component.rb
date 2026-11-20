# frozen_string_literal: true

class TimestampComponent < ViewComponent::Base
  TIMESTAMP_FIELDS = %i[day short_day date month short_month year time zone].freeze
  TIMESTAMP_FORMAT = "%A|%a|%d|%B|%b|%Y|%I:%M%p|%Z"

  TimestampParts = Struct.new(*TIMESTAMP_FIELDS)

  attr_reader :original_time, :zone, :user

  def initialize(time:, zone: nil, user: User.current_user)
    super()
    @original_time = time
    @user = user
    @user_time_zone = user.is_a?(User) && user.time_zone
    @zone = Time.find_zone(zone)&.name || @user_time_zone || Time.zone.name
    @time = formatted_time
    @user_time = user_time
  end

  def formatted_time
    return {} if original_time.blank?

    time_in_zone = original_time.in_time_zone(zone)
    TimestampParts.new(
      *time_in_zone.strftime(TIMESTAMP_FORMAT).split("|", -1)
    )
  end

  def user_time
    return if @user_time_zone.blank? || @user_time_zone == zone
    
    @user_time = original_time.in_time_zone(@user_time_zone).strftime("%I:%M%p %Z")
  end
end
