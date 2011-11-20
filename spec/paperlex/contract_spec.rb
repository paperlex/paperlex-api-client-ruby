require 'spec_helper'

describe Paperlex::Contract do
  before do
    @contract_uuid = "4776f3b030afa70d"
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @subject = Faker::Company.catch_phrase

    unless Paperlex.token
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts.json", :body => "{\"locked\":false,\"responses\":null,\"created_at\":\"2011-10-27T23:28:31Z\",\"body\":\"#{@body.gsub("\n", '\n')}\",\"current_version\":true,\"uuid\":\"#{@contract_uuid}\",\"updated_at\":\"2011-10-27T23:28:31Z\",\"number_of_identity_verifications\":1,\"subject\":\"#{@subject}\",\"number_of_signers\":2,\"signers\":[],\"signatures\":[]}"
    end
  end

  def create_contract(args = {})
    if signer_count = args[:signers]
      signer_count = Integer(signer_count)
      args[:signers] = signers = signer_count.times.map do
        Faker::Internet.email
      end

      unless Paperlex.token
        FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract_uuid}/signers.json", signers.map {|signer_email| {:body => "{\"uuid\":\"#{SecureRandom.hex(16)}\",\"email\":\"#{signer_email}\"}"} }
      end
    end
    contract = Paperlex::Contract.create({"body" => @body,"subject" => @subject,"number_of_signers" => 2}.merge(args))
  end

  describe ".all" do
    before do
      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts.json?token=", :body => %{[{"created_at":"2011-10-04T07:09:01Z","uuid":"ce883764523af12e","updated_at":"2011-10-04T07:09:01Z","subject":"NDA"},{"created_at":"2011-10-04T07:09:01Z","uuid":"0694fb3b248c8973","updated_at":"2011-10-04T07:09:01Z","subject":"Pay me"}]}
      end
    end

    it "should fetch all existing contracts" do
      @contracts = Paperlex::Contract.all
      @contracts.size.should > 1
      @contracts.each do |contract|
        contract.created_at.should be_present
        contract.updated_at.should be_present
        contract.subject.should be_present
        contract.uuid.should be_present
      end
    end
  end

  describe ".create" do
    shared_examples_for "contract creation" do
      it "should return a contract object" do
        @contract.number_of_signers.should == 2
        @contract.subject.should == @subject
        @contract.body.should == @body
        @contract.current_version.should == true
        @contract.uuid.should be_present
        @contract.updated_at.should be_present
        @contract.created_at.should be_present
      end
    end

    context "with simple parameters" do
      before do
        @contract = Paperlex::Contract.create("body" => @body,"subject" => @subject,"number_of_signers" => 2)
      end

      it_should_behave_like "contract creation"

      it "should not create signers" do
        @contract.signers.should be_empty
        @contract.signatures.should be_empty
      end
    end

    context "with signers do" do
      before do
        @signers = [Faker::Internet.email, Faker::Internet.email]

        unless Paperlex.token
          FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract_uuid}/signers.json", @signers.map {|signer_email| {:body => "{\"uuid\":\"#{SecureRandom.hex(16)}\",\"email\":\"#{signer_email}\"}"} }
        end

        @contract = Paperlex::Contract.create("body" => @body, "subject" => @subject, "number_of_signers" => 2, 'signers' => @signers)
      end

      it_should_behave_like "contract creation"

      it "should create signers" do
        @contract.signers.should_not be_empty
        @contract.signatures.should be_empty
        @contract.signers.zip(@signers).each do |signer, expected_signer|
          signer.email.should == expected_signer
        end
      end
    end
  end

  describe ".find" do
    before do
      if Paperlex.token
        contract = create_contract
        @uuid = contract.uuid
      else
        @uuid = "ce883764523af12e"
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@uuid}.json?token=", :body => %{{"responses":null,"created_at":"2011-10-04T07:09:01Z","current_version":true,"body":"This Non-Disclosure Agreement (the **Agreement**) is made as of **{{effective_date}}** (the **Effective Date**) by and between **{{party_a}}**, reachable at **{{party_a_address}}**; and **{{party_b}}**", "uuid":"#{@uuid}", "updated_at":"2011-10-04T07:09:01Z", "signers":[], "locked":true, "subject":"NDA", "number_of_signers":2, "signatures":[],"number_of_identity_verifications":1}}
      end
    end

    it "should fetch all existing contracts" do
      @contract = Paperlex::Contract.find(@uuid)
      @contract.created_at.should be_present
      @contract.updated_at.should be_present
      @contract.subject.should be_present
      @contract.uuid.should be_present
      @contract.current_version.should be_present
      @contract.body.should be_present
      @contract.signatures.should be_blank
      @contract.number_of_signers.should be_present
      @contract.signers.should be_blank
    end
  end

  describe "#html_url" do
    before do
      @uuid = "ce883764523af12e"
    end

    it "should return the html url" do
      Paperlex::Contract.new(@uuid).html_url.should == "https://sandbox.api.paperlex.com/v1/contracts/#{@uuid}.html?token=#{Paperlex.token}"
    end
  end

  describe "#save!" do
    before do
      @contract = create_contract
      FakeWeb.register_uri :put, "#{Paperlex.base_url}/contracts/#{@contract.uuid}.json", :body => "{}"
    end

    it "should send the update to api.paperlex.com" do
      @contract.body = 'Foo'
      @contract.subject = 'Bar'
      @contract.number_of_signers = 3
      Paperlex::Base.should_receive(:put).with(Paperlex::Contract.url_for(@contract.uuid), {:body => 'Foo', :subject => 'Bar', :number_of_signers => 3, :responses => @contract.responses, :signature_callback_url => @contract.signature_callback_url})
      @contract.save!
      @contract.body.should == 'Foo'
      @contract.subject.should == 'Bar'
      @contract.number_of_signers.should == 3
    end
  end

  describe "#create_signer" do
    before do
      @contract = create_contract
      @email = Faker::Internet.email
      unless Paperlex.token
        FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract_uuid}/signers.json", :body => "{\"uuid\":\"3ab109b11a083b31\",\"email\":\"#{@email}\"}"
      end
    end

    it "should create a signer" do
      signer = @contract.create_signer(:email => @email)
      signer.email.should == @email
      @contract.signers.should include(signer)
    end
  end

  describe "#fetch_signers" do
    before do
      @contract = create_contract
      @signer_emails = [Faker::Internet.email, Faker::Internet.email]

      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/signers.json?token=", {:body => "[#{@signer_emails.map {|signer_email|  "{\"uuid\":\"#{SecureRandom.hex(16)}\",\"email\":\"#{signer_email}\"}"}.join(", ")}]" }
      end
    end

    it "should update the signers" do
      @contract.signers.should be_empty
      @signers = @contract.fetch_signers
      @contract.signers.should == @signers
      @signers.should be_present
      @signers.length.should == 2
      @signers.map {|signer| signer.email }.should =~ @signer_emails
    end
  end

  describe "#fetch_signer" do
    before do
      @contract = create_contract(:signers => 2)
    end

    it "should update the signer" do
      @signer = @contract.signers.first
      @new_email = Faker::Internet.email
      @signer.email.should_not == @new_email
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/signers/#{@signer.uuid}.json?token=", {:body => "{\"uuid\":\"#{@signer.uuid}\",\"email\":\"#{@new_email}\"}" }
      @new_signer = @contract.fetch_signer(@signer.uuid)
      @new_signer.email.should == @new_email
      @contract.signers.should include(@new_signer)
      @contract.signers.should_not include(@signer)
    end
  end
end
