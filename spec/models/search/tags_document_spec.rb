require 'spec_helper'

describe Tags::Document, type: :model do
  let(:tag) { Character.create(name: "Aeneas", canonical: true, last_wrangler_id: 5) }
  let(:document) { Tags::Document.new(tag) }

  describe "#as_json" do
    it "should include whitelisted fields" do
      expect(document.as_json['name']).to eq("Aeneas")
    end

    it "should not include non-whitelisted fields" do
      expect(document.as_json['last_wrangler_id']).to be_nil
    end
  end

  describe "#suggester" do
    it "should include both type and canonical data in context" do
      contexts = document.suggester.dig(:contexts, :typeContext)
      expect(contexts).to include("Character")
      expect(contexts).to include("CanonicalCharacter")
    end
  end

  describe "#parent_data" do
    let(:fandom) { Fandom.create(name: "The Aeneid", canonical: true) }
    before do
      tag.parents = [fandom]
    end

    it "should include parent ids in their own field" do
      data = document.parent_data
      expect(data["fandom_ids"]).to eq([fandom.id])
    end

    it "should include all parent ids as strings" do
      data = document.parent_data
      expect(data["parent_ids"]).to eq([fandom.id.to_s])
    end
  end
end
