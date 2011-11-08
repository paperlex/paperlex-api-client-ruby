require 'spec_helper'

describe Paperlex::Slaw do
  before do
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @name = Faker::Company.catch_phrase
    @description = Faker::Company.catch_phrase

    unless ENV['TEST_API']
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/slaws.json", body: "{\"public\":true,\"created_at\":\"2011-10-27T23:28:31Z\",\"body\":\"#{@body.gsub("\n", '\n')}\",\"current_version\":true,\"uuid\":\"23a15b9e18d09168\",\"updated_at\":\"2011-10-27T23:28:31Z\",\"name\":\"#{@name}\",\"description\":\"#{@description}\"}"
    end
  end

  describe ".create" do
    it "should return a contract object" do
      slaw = Paperlex::Slaw.create({"body" => @body,"name" => @name,"description" => @description})
      slaw.name.should == @name
      slaw.body.should == @body
      slaw.description.should == @description
      slaw.current_version.should == true
      slaw.uuid.should be_present
      slaw.updated_at.should be_present
      slaw.created_at.should be_present
    end
  end
end
