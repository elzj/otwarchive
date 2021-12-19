# frozen_string_literal: true

require "spec_helper"

describe ChallengeSignup do
  describe "#<=>" do
    let(:pseud1) { Pseud.new(name: "zed", id: 1) }
    let(:pseud2) { Pseud.new(name: "al", id: 2) }

    let(:signup1) { ChallengeSignup.new(pseud: pseud1) }
    let(:signup2) { ChallengeSignup.new(pseud: pseud2) }

    it "sorts based on pseud name" do
      expect(signup1 <=> signup2).to eq(1)
      expect(signup2 <=> signup1).to eq(-1)
      expect([signup1, signup2].sort).to eq([signup2, signup1])
    end
  end
end
