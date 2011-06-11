require 'spec_helper'

describe Note do
  describe "#to_simplenote_content" do
    [
        {:title => 'test 1', :body => 'foobar', :content => "test 1\n\nfoobar"},
        {:title => 'test 2', :body => "\nfoobar\n", :content => "test 2\n\nfoobar"}
    ].each do |hash|
      it "should return #{hash[:content]} for a note with title #{hash[:title]} and body #{hash[:body]}" do
        note = Note.new(:title => hash[:title], :body => hash[:body])
        note.to_simplenote_content.should == hash[:content]
      end
    end
  end

  context "named_scopes" do

    describe "#modified_locally" do
      it "scopes to notes that are modified locally" do
        Factory(:note, :modified_locally => false)
        Factory(:note, :modified_locally => true)

        should_be_a_subset(Note.all, Note.modified_locally) do |note|
          note.modified_locally == true
        end
      end
    end

  end

end
