require 'spec_helper'
require 'active_support/inflector'

describe AutoloadFor do

  describe '.autoload_for' do

    let(:fixtures_dir) { (File.join(File.expand_path('../..', __FILE__), 'fixtures')) }

    it "should not have classes or modules to be loaded if not called" do
      expect { Animal }.to raise_error
      expect { Animal::Mammal }.to raise_error
      expect { Animal::Mammal::Cat }.to raise_error
      expect { Animal::Mammal::Dog }.to raise_error
      expect { Animal::Fish }.to raise_error
      expect { Zoo }.to raise_error

      AutoloadFor.autoload_for fixtures_dir

      expect { Animal }.to_not raise_error
      expect { Animal::Mammal }.to_not raise_error
      expect { Animal::Mammal::Cat }.to_not raise_error
      expect { Animal::Mammal::Dog }.to_not raise_error
      expect { Animal::Fish }.to_not raise_error
      expect { Zoo }.to_not raise_error

    end

  end

end
