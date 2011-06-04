require 'spec_helper'

describe SimplenoteMediator do
  before :each do
    VCR.use_cassette('simplenote') { @app = App.new }
  end

  describe '#pull' do

    context 'local note present that is deleted on the server' do
      before do
        @deleted_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjay-cIDA'
        Factory(:note, :simplenote_key => @deleted_key)
      end

      it 'deletes the note locally' do
        expect { VCR.use_cassette('simplenote') { @app.simplenote.pull } }.to change { Note.find_by_simplenote_key(@deleted_key).present? }.from(true).to(false)
      end
    end

    context 'local note present that is updated on the server' do

      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_modify => DateTime.parse("2011-06-02 22:57:29.265000"), :body => 'some ish',  :updated_at => Time.now-1.day, :created_at => Time.now-1.day)
      end

      it "updates note title" do
        expect { VCR.use_cassette('simplenote') { @app.simplenote.pull } }.to change { @note.reload.title }.to('second')
      end
      it "updates note body" do
        expect { VCR.use_cassette('simplenote') { @app.simplenote.pull } }.to change { @note.reload.body }.to('some more ish')
      end
      it "updates simplenote_modify time" do
        expect { VCR.use_cassette('simplenote') { @app.simplenote.pull } }.to change { @note.reload.simplenote_modify }.to(DateTime.parse('2011-06-03 22:57:29.265000'))
      end
    end

    context "note on server that doesn't exist locally" do
      before do
        @new_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRisgdcIDA'
      end

      it 'creates the note' do
        expect { VCR.use_cassette('simplenote') { @app.simplenote.pull } }.to change { Note.find_by_simplenote_key(@new_key).present? }.from(false).to(true)
      end
    end
  end

  describe '#push' do
    it 'updates any notes on the server that are on the local queue with updates'
  end

  describe '#setup_push_queue' do
    it 'adds all local notes to be pushed to the push queue' do

    end
  end

  describe "#parse_title and #parse_body" do
    [
        {
            :string => "first\n\n   third\nfourth  ",
            :title => "first",
            :body => "third\nfourth"
        },
        {
            :string => "first\nsecond\nthird",
            :title => "first",
            :body => "second\nthird"
        },

    ].each do |hash|
      it "returns #{hash[:title]} as the title for #{hash[:string]}" do
        @app.simplenote.parse_title(hash[:string]).should == hash[:title]
      end

      it "returns #{hash[:body]} as the body for #{hash[:string]}" do
        @app.simplenote.parse_body(hash[:string]).should == hash[:body]
      end
    end
  end
end