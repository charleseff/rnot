require 'spec_helper'

describe SimplenoteMediator do
  before do
    @app = App.new
    @simplenote = @app.simplenote
  end

  describe '#get_note_hashes' do
    it 'gets all note hashes even if it has to call for the index more than once' do
      data = VCR.use_cassette('simplenote/get_note_hashes', :record => :none) { @simplenote.get_note_hashes(:length=>2) }
      data.size.should == 22
    end
  end

  describe '#pull' do

    context 'local note not present that is deleted on the server' do
      it 'does not create the note' do
        @deleted_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjay-cIDA'
        expect { VCR.use_cassette('simplenote/pull', :record => :none) { @simplenote.pull } }.to_not change { Note.find_by_simplenote_key(@deleted_key).present? }
      end
    end

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
      it "updates modified value in the notes list gui"
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

      it 'creates a new note note' do
        expect { VCR.use_cassette('simplenote/pull') { @simplenote.pull } }.to change { Note.find_by_simplenote_key(@new_key).present? }.from(false).to(true)
      end
      it "adds note to the notes list gui"

      context "another note exists locally with the same title" do
        before do
          @note = Factory(:note, :title => 'third', :modified_locally => true)
        end
        it "deletes that note" do
          VCR.use_cassette('simplenote/pull') { @simplenote.pull }
          lambda { @note.reload }.should raise_error ActiveRecord::RecordNotFound
        end

        it "creates a new note" do
          expect { VCR.use_cassette('simplenote/pull') { @simplenote.pull } }.to change { Note.find_by_simplenote_key(@new_key).present? }.from(false).to(true)
        end
      end

    end

    context "local note is modified locally and also has an update from the server" do
      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 1, :body => 'some ish', :updated_at => Time.now-1.day, :created_at => Time.now-1.day, :modified_locally => true)
      end
      it "should mark the note as not modified locally" do
        expect { VCR.use_cassette('simplenote/pull') { @simplenote.pull } }.to change { @note.reload.modified_locally? }.from(true).to(false)
      end

    end
  end

  describe '#push' do

    context 'note is modified locally that exists on server' do
      before do
        @updated_key = 'agtzaW1wbGUtbm90ZXINCxIETm90ZRjduukIDA'
        @note = Factory(:note, :simplenote_key => @updated_key, :simplenote_syncnum => 1, :body => 'some ish',
                        :updated_at => Time.now-1.day, :created_at => Time.now-1.day, :title => 'tha title', :modified_locally => true)
      end
      it "updates note's server syncnum" do
        before_syncnum = @note.reload.simplenote_syncnum
        VCR.use_cassette('simplenote/push') { @simplenote.push }
        @note.reload.simplenote_syncnum.should > before_syncnum
      end
      it 'sets the note as not modified locally' do
        expect { VCR.use_cassette('simplenote/push') { @simplenote.push } }.to change { @note.reload.modified_locally? }.from(true).to(false)
      end
    end

    context 'note modified locally is new' do
      before do
        @note = Factory(:note, :body => 'the real body', :updated_at => Time.now-1.day, :created_at => Time.now-1.day,
                        :title => 'tha real title', :modified_locally=>true)
      end
      it 'updates local note with server key' do
        expect { VCR.use_cassette('simplenote/push_new') { @simplenote.push } }.to change { @note.reload.simplenote_key.present? }.from(false).to(true)
      end
      it 'updates local note with syncnum' do
        expect { VCR.use_cassette('simplenote/push_new') { @simplenote.push } }.to change { @note.reload.simplenote_syncnum.present? }.from(false).to(true)
      end
      it 'sets modified locally to false' do
        expect { VCR.use_cassette('simplenote/push_new') { @simplenote.push } }.to change { @note.reload.modified_locally? }.from(true).to(false)
      end
      it 'adds note to the server' do
        VCR.use_cassette('simplenote/push_new_ands_to_index') do
          @simplenote.push
          @simplenote.get_note_hashes.map { |h| h['key'] }.should include(@note.reload.simplenote_key)
        end
      end
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
        @simplenote.parse_title(hash[:string]).should == hash[:title]
      end

      it "returns #{hash[:body]} as the body for #{hash[:string]}" do
        @simplenote.parse_body(hash[:string]).should == hash[:body]
      end
    end
  end
end