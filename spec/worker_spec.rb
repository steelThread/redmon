require ::File.expand_path('../spec_helper.rb', __FILE__)

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