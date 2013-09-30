# encoding: UTF-8
require 'spec_helper'

describe TagForm do
  
  before do
    @tag = Freeform.find_or_create_by_name "Foobar"
    @form = TagForm.new(@tag)
  end
  
  it "is associated with a tag" do
    @form.tag.should == @tag
  end
  
  it "should respect tag validation rules" do
    @form.update(name: '').should be_false
    @form.errors.keys.should include(:name)
  end
  
  it "shouldn't allow you to make a canonical tag unwrangleable" do
    @form.update(canonical: true, unwrangleable: true).should be_false
    @form.errors.keys.should include(:unwrangleable)
  end
  
  it "shouldn't allow you to make a tag with a merger unwrangleable" do
    @form.update(merger_id: 6, unwrangleable: true).should be_false
    @form.errors.keys.should include(:unwrangleable)
  end
  
  describe "syn_string=" do
    before do
      @canonical = Freeform.create(name: "Foobar Official", canonical: true)
    end
    
    it "should make this tag the merger of a canonical tag" do
      @form.update("syn_string" => "Foobar Official")
      @form.tag.merger.should == @canonical
    end
    
    it "should create a new canonical if the tag doesn't already exist" do
      @form.update("syn_string" => "Foobar New Canonical")
      @form.tag.merger.should_not be_nil
      @form.tag.merger.name.should == "Foobar New Canonical"
    end
    
    it "should raise a validation error if you try to use a non-canonical tag" do
      @noncanonical = Freeform.create(name: "Fobar")
      @form.update("syn_string" => "Fobar").should be_false
      @form.errors[:base].to_s.should match /is not a canonical tag/
    end
  end
end