require 'spec_helper'

describe "Redmon" do
  describe "#configure" do
    it "should allow block style config" do
      Redmon.configure do |config|
        config.app = false
      end
      expect(Redmon.config.app).to be false
    end
  end
end

describe "Config" do
  subject { Redmon::Config.new }
  describe "#initialize" do
    it "should apply the defaults" do
      Redmon::Config::DEFAULTS.each do |k,v|
        expect(subject.send(k)).to be v
      end
    end
  end

  describe "#apply" do
    it "should apply the passed options hash" do
      expect(subject.app).to be true
      expect(subject.worker).to be true

      subject.apply :app => false, :worker => false
      expect(subject.app).to be false
      expect(subject.worker).to be false
    end
  end
end
