require 'spec_helper'

describe Paperlex::Slaw do
  before do
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @name = Faker::Company.catch_phrase
    @description = Faker::Company.catch_phrase

    unless Paperlex.token
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/slaws.json", :body => "{\"public\":true,\"body\":\"#{@body.gsub("\n", '\n')}\",\"uuid\":\"23a15b9e18d09168\",\"name\":\"#{@name}\",\"description\":\"#{@description}\"}"
    end
  end

  def create_slaw
    Paperlex::Slaw.create({"body" => @body,"name" => @name,"description" => @description})
  end

  describe ".all" do
    before do
      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/slaws.json", :body => %{[{"name":"Non-Disclosure Agreement","public":true,"uuid":"23a15b9e18d09168","description":"Non-Disclosure Agreement"}]}
      end
    end

    it "should fetch all existing slaws" do
      @slaws = Paperlex::Slaw.all
      @slaws.size.should be > 0
      @slaws.each do |slaw|
        slaw.name.should be_present
        slaw.public.should be_boolean
        slaw.uuid.should be_present
        slaw.description.should be_present
      end
    end
  end

  describe ".create" do
    it "should return a slaw object" do
      slaw = Paperlex::Slaw.create({"body" => @body,"name" => @name,"description" => @description})
      slaw.name.should == @name
      slaw.body.should == @body
      slaw.description.should == @description
      slaw.uuid.should be_present
    end
  end

  describe ".find" do
    before do
      @name = "Non-Disclosure Agreement"
      @description = "Non-Disclosure Agreement Description"
      @body = "This Non-Disclosure Agreement (the **Agreement**) is made as of **{{effective_date}}** (the **Effective Date**) by and between **{{party_a}}**, reachable at **{{party_a_address}}**; and **{{party_b}}**"
      @response_keys = %w[party_a party_b effective_date party_a_address]
      if Paperlex.token
        slaw = Paperlex::Slaw.create(:name => @name, :description => @description, :body => @body)
        @uuid = slaw.uuid
      else
        @uuid = '23a15b9e18d09168'
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/slaws/#{@uuid}.json", :body => %{{"name":"#{@name}","public":true,"body":"#{@body}","uuid":"#{@uuid}","description":"#{@description}","response_keys":#{@response_keys.to_json}}}
      end
    end

    it "should create a slaw with just a uuid" do
      slaw = Paperlex::Slaw.find(@uuid)
      slaw.response_keys.should =~ @response_keys
      slaw.uuid.should == @uuid
      slaw.body.should == @body
      slaw.description.should == @description
      slaw.name.should == @name
      slaw.public.should be_boolean
    end
  end

  describe "#save!" do
    before do
      @slaw = create_slaw
      unless Paperlex.token
        FakeWeb.register_uri :put, "#{Paperlex.base_url}/slaws/#{@slaw.uuid}.json", :body => "{}"
      end
    end

    it "should send the update to api.paperlex.com" do
      @slaw.body = 'Foo'
      @slaw.name = 'Bar'
      @slaw.description = 'Baz'
      Paperlex::Base.should_receive(:put).with(Paperlex::Slaw.url_for(@slaw.uuid), :slaw => {:body => 'Foo', :name => 'Bar', :description => 'Baz'})
      @slaw.save!
      @slaw.body.should == 'Foo'
      @slaw.name.should == 'Bar'
      @slaw.description.should == 'Baz'
    end
  end

  describe "#destory" do
    before do
      @slaw = create_slaw
      unless Paperlex.token
        FakeWeb.register_uri :delete, "#{Paperlex.base_url}/slaws/#{@slaw.uuid}.json", :body => "{}"
      end
    end

    it "should ping api.paperlex.com" do
      Paperlex::Base.should_receive(:delete).with(Paperlex::Slaw.url_for(@slaw.uuid))
      @slaw.destroy
    end
  end

  describe "#versions" do
    before do
      @slaw = create_slaw
      @slaw.body = "Foo"
      @slaw.save!
    end

    it "should return details of the various versions of the slaw" do
      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/slaws/#{@slaw.uuid}/versions.json", :body => %{[{"version":1,"event":"update"},{"version":2,"event":"update"},{"version":3,"event":"update"}]}
      end
      versions = @slaw.versions
      versions.size.should be > 0
      versions.each do |version|
        version.should be_an_instance_of(Paperlex::Version)
        version.version.should be_present
        version.event.should be_present
      end
    end
  end

  describe "#at_version" do
    before do
      @slaw = create_slaw
    end

    context "when the version exists" do
      before do
        @slaw.body = "Foo"
        @slaw.save!
      end

      it "should return the given version of the slaw" do
        @version_index = 1
        unless Paperlex.token
          FakeWeb.register_uri :get, "#{Paperlex.base_url}/slaws/#{@slaw.uuid}/versions/#{@version_index}.json", :body => %{{"name":"Non-Disclosure Agreement","public":true,"body":"This Non-Disclosure Agreement","uuid":"23a15b9e18d09168","description":"Non-Disclosure Agreement"}}
        end
        slaw_version = @slaw.version_at(@version_index)
        slaw_version.public.should be_boolean
        slaw_version.description.should be_present
        slaw_version.name.should be_present
        slaw_version.uuid.should be_present
      end
    end
  end

  describe "#revert_to_version" do
    before do
      @slaw = create_slaw
    end

    context "when the version exists" do
      before do
        @slaw.body = "Foo"
        @slaw.save!
      end

      it "should return the given version of the slaw" do
        @version_index = 1
        unless Paperlex.token
          FakeWeb.register_uri :post, "#{Paperlex.base_url}/slaws/#{@slaw.uuid}/versions/#{@version_index}/revert.json", :body => %{{"name":"Non-Disclosure Agreement","public":true,"body":"This Non-Disclosure Agreement","uuid":"23a15b9e18d09168","description":"Non-Disclosure Agreement"}}
        end
        slaw_version = @slaw.revert_to_version(@version_index)
        slaw_version.public.should be_boolean
        slaw_version.description.should be_present
        slaw_version.name.should be_present
        slaw_version.uuid.should be_present
      end
    end
  end
end
