require 'spec_helper'

RSpec.describe DraftPoster, type: :model do
  describe '#valid?' do
    it "should return false when required data is missing" do
      poster = DraftPoster.new(Draft.new)
      expect(poster).not_to be_valid
      expect(poster.errors).to eq(
        ["Title is missing", "Fandom is missing", "Rating is missing", "Warning is missing", "Creator is missing"]
      )
    end
  end
  describe '#post!' do
    let(:user) { create(:user) }
    let(:work_info) do
      {
        title: "A new work",
        chapter: {
          content: "With plenty of content",
        },
        fandoms: "Amazing Fandom",
        ratings: "Not Rated",
        warnings: "No Archive Warnings Apply",
        user_id: user.id
      }
    end

    let(:draft) { Draft.create(work_info) }

    context "without the right data" do
      before do
        draft.set_data(chapter: { content: 'z' })
      end

      it "should not save" do
        poster = DraftPoster.new(draft)
        expect(poster.post!).to be_falsey
        expect(poster.errors.length).to eq(1)
      end

      it "should not delete the draft" do
        DraftPoster.new(draft).post!
        expect { draft.reload }.not_to raise_error
      end
    end
    context "with all required data" do
      it "should post a work" do
        poster = DraftPoster.new(draft)
        work = poster.post!

        expect(work).not_to be_falsey
        expect(poster.errors).to be_empty
        expect(work.title).to eq("A new work")
        expect { draft.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
