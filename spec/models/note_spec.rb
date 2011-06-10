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
end
