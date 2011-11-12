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

  describe ".all" do
    before do
      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/slaws.json", body: %{[{"name":"Non-Disclosure Agreement","public":true,"uuid":"23a15b9e18d09168","description":"Non-Disclosure Agreement"}]}
      end
    end

    it "should fetch all existing contracts" do
      @slaws = Paperlex::Slaw.all
      @slaws.size.should == 1
      @slaws.each do |slaw|
        slaw.name.should be_present
        slaw.public.should be_present
        slaw.uuid.should be_present
        slaw.description.should be_present
      end
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

  describe ".find" do
    it "should create a slaw with just a uuid" do
      slaw = Paperlex::Slaw.find('23a15b9e18d09168')
      slaw.uuid.should == '23a15b9e18d09168'
    end
  end
end
