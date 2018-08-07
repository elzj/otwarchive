# -*- coding: utf-8 -*-

require 'string_tokenizer'

describe StringTokenizer do

  describe ".tokenize" do
    context "on nil" do
      it "should not error" do
        tokens = StringTokenizer.tokenize(nil)
        expect(tokens).to eq([])
      end
    end

    context "with various punctuation" do
      it "should leave apostrophes alone" do
        tokens = StringTokenizer.tokenize("The Philosopher's Stone")
        expect(tokens).to include("Philosopher's Stone")
      end

      it "should split on slashes" do
        tokens = StringTokenizer.tokenize("Hermione/Ron")
        expect(tokens).to include("Ron")
      end
    end

    context "on a string with small words" do
      let(:tokens) { StringTokenizer.tokenize("Death of a Salesman") }
      it "should always include the full string" do
        expect(tokens.first).to eq("Death of a Salesman")
      end

      it "should include one- and two-letter words as tokens" do
        expect(tokens.length).to eq(4)
        expect(tokens).to include("a Salesman")
      end
    end

    context "on a very long string" do
      let(:tokens) do
        str = "bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla"
        StringTokenizer.tokenize(str)
      end
      it "should only return the first 20 tokens" do
        expect(tokens.length).to eq(20)
      end
    end
  end
end
