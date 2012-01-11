require ::File.expand_path('../spec_helper.rb', __FILE__)

include Rack::Test::Methods

describe "app" do

  def app
    Redmon::App.new Redmon::DEFAULT_OPTS
  end

  describe "GET /" do
    it "should render the app" do
      get "/"
      last_response.should be_ok
      last_response.body.include?('Redmon')
    end
  end

  describe "GET /info" do
    it "should render a single json result" do
      stub_redis ['redmon:redis.info', -1, -1]
      get "/info"
      last_response.should be_ok
      last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
    end

    it "should request the correct # of historical info records from redis" do
      stub_redis ['redmon:redis.info', -666, -1]
      get "/info?count=666"
      last_response.should be_ok
    end

    def stub_redis(args)
      redis = Redis.new
      redis.should_receive(:zrange).with(*args).and_return({})
      Redis.stub(:new).and_return(redis)
    end
  end

  describe "GET /cli" do

  end
end