require "spec_helper"

describe TimestampComponent, type: :component do
  let(:time) { Time.rfc3339("1999-12-31T16:00:00Z") }
  let(:zone_tokyo) { Time.find_zone("Asia/Tokyo") }

  it "returns a message if no time is present" do
    component = TimestampComponent.new(time: nil)
    render_inline(component)
    expect(page.text).to eq("(no time specified)")
  end

  context "when a time zone is provided" do
    it "is used if valid" do
      component = TimestampComponent.new(
        time: time,
        zone: zone_tokyo.name
      )
      render_inline(component)
      expect(page).to have_css "abbr[title='Saturday']", text: "Sat"
      expect(page).to have_css "abbr[title='January']", text: "Jan"
      text_content = page.text.squish
      expect(text_content).to eq("Sat 01 Jan 2000 01:00AM JST")
    end

    it "displays both that and the user time zone" do
      user = User.new(login: "foo")
      user.preference = Preference.new(time_zone: "Kyiv")
      component = TimestampComponent.new(
        time: time,
        zone: zone_tokyo,
        user: user
      )
      render_inline(component)
      expect(page).to have_css "abbr[title='Saturday']", text: "Sat"

      text_content = page.text.squish
      expect(text_content).to eq("Sat 01 Jan 2000 01:00AM JST (06:00PM EET)")
    end

    it "falls back to the user time zone if invalid" do
      user = User.new(login: "foo")
      user.preference = Preference.new(time_zone: "Kyiv")
      component = TimestampComponent.new(
        time: time,
        zone: "Garbage time zone",
        user: user
      )
      render_inline(component)
      text_content = page.text.squish
      expect(text_content).to eq("Fri 31 Dec 1999 06:00PM EET")
    end

    it "falls back to UTC if invalid and no user time zone is present" do
      component = TimestampComponent.new(
        time: time,
        zone: "Invalid time zone"
      )
      render_inline(component)

      expect(page).to have_css "abbr[title='Friday']", text: "Fri"
      expect(page.text).to match("UTC")
    end
  end

  context "for a user with a time zone" do
    let(:user) do
      user = User.new(login: "foo")
      user.preference = Preference.new(time_zone: "Asia/Tokyo")
      user
    end

    it "returns localized time" do
      component = TimestampComponent.new(
        time: time,
        user: user
      )
      render_inline(component)
      expect(page.text.squish).to eq("Sat 01 Jan 2000 01:00AM JST")
    end
  end

  context "for a user without a time zone" do
    let(:user) do
      user = User.new(login: "foo")
      user.preference = Preference.new
      user
    end

    it "falls back to UTC" do
      component = TimestampComponent.new(
        time: time,
        user: user
      )
      render_inline(component)
      expect(page.text.squish).to eq("Fri 31 Dec 1999 04:00PM UTC")
    end
  end
end
