require 'spec_helper'

describe Rnot::Config do
  before do
    @app = App.new
  end
  describe "#encrypt_simplenote_password and #decrypted_simplenote_password" do
    it "should encrypt and decrypt the password" do
      password = "oiwjfoiew"
      @app.encrypt_simplenote_password(password)
      @app.decrypted_simplenote_password.should == password
    end
  end

  describe "#config_hash and #config_hash=" do
    it "should spit out what gets put in" do
      hash = {:owkij=> 'owijef', :owifje => {:woije=>'owiejfew', :woeijfe => 'woeijf'}}
      @app.config_hash = hash
      @app.config_hash.should == hash
    end
  end

end