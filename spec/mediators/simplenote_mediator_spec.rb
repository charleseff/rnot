require 'spec_helper'

describe SimplenoteMediator do
  before { @simplenote = SimplenoteMediator.new }

  describe '#get_note_hashes' do
    it 'gets all note hashes even if it has to call for the index more than once' do
      data = VCR.use_cassette('simplenote/get_note_hashes', :record => :none) { @simplenote.get_note_hashes(:length=>2) }
      data.size.should == 22
    end
  end

  describe '#pull' do

    context 'local note present that is deleted on the server' do
      before do
        @deleted_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjay-cIDA'
        Factory(:note, :simplenote_key => @deleted_key)
      end

      it 'deletes the note locally' do
        expect { VCR.use_cassette('simplenote/pull', :record => :none) { @simplenote.pull } }.to change { Note.find_by_simplenote_key(@deleted_key).present? }.from(true).to(false)
      end
    end

    context 'local note present that is updated on the server' do

      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 1, :body => 'doo dah', :updated_at => Time.now-1.day, :created_at => Time.now-1.day)
      end

      it "updates note title" do
        expect { VCR.use_cassette('simplenote/pull', :record => :none) { @simplenote.pull } }.to change { @note.reload.title }.to('tha title')
      end
      it "updates note body" do
        expect { VCR.use_cassette('simplenote/pull', :record => :none) { @simplenote.pull } }.to change { @note.reload.body }.from('doo dah').to('some ish')
      end
      it "updates simplenote_syncnum" do
        expect { VCR.use_cassette('simplenote/pull', :record => :none) { @simplenote.pull } }.to
        change { @note.reload.simplenote_syncnum }.to(2)
      end
      it "updates updated_at time" do
        updated_at_before = @note.updated_at
        VCR.use_cassette('simplenote/pull') { @simplenote.pull }
        @note.reload.updated_at.should > updated_at_before
      end
    end

    context 'local note present that is not updated on the server' do
      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 7,
                        :body => 'some ish', :updated_at => Time.now-1.day, :created_at => Time.now-1.day)
      end

      it "does not update updated_at time" do
        updated_at_before = @note.updated_at
        VCR.use_cassette('simplenote/pull') { @simplenote.pull }
        @note.reload.updated_at.should == updated_at_before
      end
    end

    context "note on server that doesn't exist locally" do
      before do
        @new_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRisgdcIDA'
      end

      it 'creates the note' do
        expect { VCR.use_cassette('simplenote/pull') { @simplenote.pull } }.to change { Note.find_by_simplenote_key(@new_key).present? }.from(false).to(true)
      end
    end

    context "local note is on the push queue that also has an update from the server" do
      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 1, :body => 'some ish', :updated_at => Time.now-1.day, :created_at => Time.now-1.day)
        @simplenote.notes_to_push << @note
      end
      it "should remove the note from the push queue" do
        VCR.use_cassette('simplenote/pull') { @simplenote.pull }
        @simplenote.notes_to_push.should_not include @note

      end

    end
  end

  describe '#push' do

    context 'note exists on local queue that exists on server' do
      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 1, :body => 'some ish', :updated_at => Time.now-1.day, :created_at => Time.now-1.day, :title => 'tha title')
        @simplenote.notes_to_push << @note
      end
      it "updates note's server syncnum" do
        before_syncnum = @note.reload.simplenote_syncnum
        VCR.use_cassette('simplenote_push') { @simplenote.push }
        @note.reload.simplenote_syncnum.should > before_syncnum
      end
      it 'removes note from the queue' do
        @simplenote.notes_to_push.should include @note
        VCR.use_cassette('simplenote_push') { @simplenote.push }
        @simplenote.notes_to_push.should_not include @note
      end
    end

    context 'notes on the local queue are new' do
      it 'adds note to the server'
      it 'updates local note with server key and modify time'
      it 'removes note from the queue'
    end
  end

  describe '#setup_push_queue' do
    it 'adds all local notes to be pushed to the push queue'
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
        @simplenote.parse_title(hash[:string]).should == hash[:title]
      end

      it "returns #{hash[:body]} as the body for #{hash[:string]}" do
        @simplenote.parse_body(hash[:string]).should == hash[:body]
      end
    end
  end
end