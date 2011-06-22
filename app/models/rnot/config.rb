require 'openssl'
require 'digest/sha1'

module Rnot::Config

  KEY = Digest::SHA1.hexdigest("woiuehf(*$#H(8hf9*h98FH438oijFOEWIJHOIUHRGoiw090()(U)")

  def encrypt_simplenote_password(password)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = KEY
    c.iv = iv = c.random_iv
    e = c.update(password)
    e << c.final
    self.config_hash = config_hash.merge(:simplenote=>{:iv=>iv, :e=>e})

  end

  def decrypted_simplenote_password
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = KEY
    hash = config_hash

    c.iv = hash[:simplenote][:iv]
    d = c.update(hash[:simplenote][:e])
    d << c.final

    d
  end

  def config_hash
    if File.exists? self.class.config_file
      File.open(self.class.config_file, 'rb') { |f| Marshal.load(f) }
    else
      nil
    end
  end

  def config_hash= h
    File.open(self.class.config_file, "wb") { |f| Marshal.dump(h, f) }
  end

  module ClassMethods
    def config_file
      File.join(App::notes_dir, 'config')
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end