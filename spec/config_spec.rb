require 'spec_helper'

describe "Redmon" do
  describe "#configure" do
    it "should allow block style config" do
      Redmon.configure do |config|
        config.app = false
      end
      Redmon.config.app.should be_false
    end
  end
end

describe "Config" do
  subject { Redmon::Config.new }
  describe "#initialize" do
    it "should apply the defaults" do
      Redmon::Config::DEFAULTS.each do |k,v|
        subject.send(k).should === v
      end
    end
  end

  describe "#apply" do
    it "should apply the passed options hash" do
      subject.app.should be_true
      subject.worker.should be_true

      subject.apply :app => false, :worker => false
      subject.app.should be_false
      subject.worker.should be_false
    end
  end
end
