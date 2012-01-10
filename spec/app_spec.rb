require ::File.expand_path('../spec_helper.rb', __FILE__)

include Rack::Test::Methods

describe "app" do

  def app
    Redmon::App.new(Redmon::DEFAULT_OPTS)
  end

  context "/" do
    it "should render the app" do
      get "/"
      last_response.should be_ok
      last_response.body.include?('Redmon')
    end
  end

  context "/info" do
    it "should render json" do
      get "/info"
      last_response.should be_ok
      last_response.headers["Content-Type"].should == "application/json;charset=utf-8"
    end

    it "should render the correct # of results" do
      get "/info?count=1"
      JSON.parse(last_response.body).length.should == 1

      get "/info?count=2"
      JSON.parse(last_response.body).length.should == 2
    end
  end

  context "/cli" do

  end
end