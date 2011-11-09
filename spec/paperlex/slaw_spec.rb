require 'spec_helper'

describe Paperlex::Slaw do
  before do
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @name = Faker::Company.catch_phrase
    @description = Faker::Company.catch_phrase

    unless Paperlex.token
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/slaws.json", body: "{\"public\":true,\"body\":\"#{@body.gsub("\n", '\n')}\",\"uuid\":\"23a15b9e18d09168\",\"name\":\"#{@name}\",\"description\":\"#{@description}\"}"
    end
  end

  describe ".create" do
    it "should return a contract object" do
      slaw = Paperlex::Slaw.create({"body" => @body,"name" => @name,"description" => @description})
      slaw.name.should == @name
      slaw.body.should == @body
      slaw.description.should == @description
      slaw.uuid.should be_present
    end
  end
end
