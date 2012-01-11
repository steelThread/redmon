require 'spec_helper'

describe "worker" do

  before(:all) do
    @worker = Redmon::Worker.new(Redmon::DEFAULT_OPTS)
  end

  describe "run!" do
    it "should poll redis for info" do
      pending "i'm tired (:"
    end
  end

end