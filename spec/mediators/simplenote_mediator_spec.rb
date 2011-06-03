require 'spec_helper'

describe SimplenoteMediator do
  before :each do
    @app = App.new
  end

  describe '#pull' do
    it 'deletes any notes locally that are marked as deleted on the server' do
      VCR.use_cassette('simplenote') do
        simplenote = @app.send(:simplenote)
        simplenote.get_index
      end
    end

    it 'updates any notes locally that have newer modified times on the server'
  end

  describe '#push' do
    it 'updates any notes on the server that are on the local queue with updates'
  end

  describe '#initial_sync' do
    it 'pushes all local notes and updates their meta-data'

    it 'pulls all server notes'
  end

  describe '#setup_push_queue' do
    it 'adds all local notes to be pushed to the push queue' do

    end
  end
end