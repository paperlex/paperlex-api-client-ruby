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

      if Paperlex.token
        @signer_emails.each do |email|
          Paperlex::Contract::Signers[@contract.uuid].create(:email => email)
        end
      else
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

    shared_examples_for "successful signer fetch" do
      it "should fetch the new signer data" do
        @new_email = Faker::Internet.email
        @signer.email.should_not == @new_email
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/signers/#{@signer.uuid}.json?token=", {:body => "{\"uuid\":\"#{@signer.uuid}\",\"email\":\"#{@new_email}\"}" }
        @new_signer = @contract.fetch_signer(@identifier)
        @new_signer.email.should == @new_email
        @contract.signers.should include(@new_signer)
        @contract.signers.should_not include(@signer)
      end
    end

    context "when provided a uuid" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer.uuid
      end
      it_should_behave_like "successful signer fetch"
    end

    context "when provided a signer" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer
      end
      it_should_behave_like "successful signer fetch"
    end
  end

  describe "#update_signer" do
    before do
      @contract = create_contract(:signers => 2)
    end

    shared_examples_for "successful signer update" do
      it "should update the signer" do
        @new_email = Faker::Internet.email
        @signer.email.should_not == @new_email
        FakeWeb.register_uri :put, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/signers/#{@signer.uuid}.json", {:body => "{\"uuid\":\"#{@signer.uuid}\",\"email\":\"#{@new_email}\"}" }
        @new_signer = @contract.update_signer(@identifier, {:email => @new_email})
        @new_signer.email.should == @new_email
        @contract.signers.should include(@new_signer)
        @contract.signers.should_not include(@signer)
      end
    end

    context "when provided a uuid" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer.uuid
      end
      it_should_behave_like "successful signer update"
    end

    context "when provided a signer" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer
      end
      it_should_behave_like "successful signer update"
    end
  end

  describe "#delete_signer" do
    before do
      @contract = create_contract(:signers => 2)
    end

    shared_examples_for "successful signer delete" do
      it "should delete the signer" do
        @signer = @contract.signers.first
        @other_signer = @contract.signers.last
        FakeWeb.register_uri :delete, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/signers/#{@signer.uuid}.json", {:body => "{\"uuid\":\"#{@signer.uuid}\",\"email\":\"#{@signer.email}\"}" }
        @contract.delete_signer(@identifier)
        @contract.signers.should_not include(@signer)
        @contract.signers.should include(@other_signer)
      end
    end

    context "when provided a uuid" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer.uuid
      end
      it_should_behave_like "successful signer delete"
    end

    context "when provided a signer" do
      before do
        @signer = @contract.signers.first
        @identifier = @signer
      end
      it_should_behave_like "successful signer delete"
    end
  end

  describe "#create_review_session" do
    before do
      @contract = create_contract
      @email = Faker::Internet.email
      unless Paperlex.token
        FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/review_sessions.json", :body => %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"d9df3765905e7695","token":"71fcd58ed9735cad","url":"https://sandbox.api.paperlex.com/v1/contracts/ce883764523af12e/review?token=71fcd58ed9735cad","email":"#{@email}"}}
      end
    end

    it "should create a review_session" do
      review_session = @contract.create_review_session(:email => @email)
      review_session.email.should == @email
      @contract.review_sessions.should include(review_session)
    end
  end

  describe "#fetch_review_sessions" do
    before do
      @contract = create_contract
      @review_session_emails = [Faker::Internet.email, Faker::Internet.email]

      unless Paperlex.token
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/review_sessions.json?token=", {:body => "[#{@review_session_emails.map {|review_session_email|  %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"#{SecureRandom.hex(16)}","token":"#{SecureRandom.hex(16)}","url":"https://sandbox.api.paperlex.com/v1/contracts/#{@contract.uuid}/review?token=#{SecureRandom.hex(16)}","email":"#{review_session_email}\"}}}.join(", ")}]" }
      end
    end

    it "should update the review_sessions" do
      @contract.review_sessions.should be_empty
      @review_sessions = @contract.fetch_review_sessions
      @contract.review_sessions.should == @review_sessions
      @review_sessions.should be_present
      @review_sessions.length.should == 2
      @review_sessions.each do |review_session|
        @review_session_emails.should include(review_session.email)
        review_session.uuid.should be_present
        review_session.token.should be_present
        review_session.url.should be_present
        review_session.email.should be_present
        review_session.expires_at.should be_present
      end
    end
  end

  describe "#fetch_review_session" do
    before do
      @contract = create_contract
      @contract.create_review_session(:email => Faker::Internet.email)
    end

    shared_examples_for "successful review_session fetch" do
      it "should fetch the new review_session data" do
        @new_email = Faker::Internet.email
        @review_session.email.should_not == @new_email
        FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/review_sessions/#{@review_session.uuid}.json?token=", {:body => %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"#{@review_session.uuid}","token":"#{@review_session.token}","url":"https://sandbox.api.paperlex.com/v1/contracts/ce883764523af12e/review?token=71fcd58ed9735cad","email":"#{@new_email}"}} }
        @new_review_session = @contract.fetch_review_session(@identifier)
        @new_review_session.email.should == @new_email
        @contract.review_sessions.should include(@new_review_session)
        @contract.review_sessions.should_not include(@review_session)
      end
    end

    context "when provided a uuid" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session.uuid
      end
      it_should_behave_like "successful review_session fetch"
    end

    context "when provided a review_session" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session
      end
      it_should_behave_like "successful review_session fetch"
    end
  end

  describe "#update_review_session" do
    before do
      @contract = create_contract
      @contract.create_review_session(:email => Faker::Internet.email)
    end

    shared_examples_for "successful review_session update" do
      it "should update the review_session" do
        @new_email = Faker::Internet.email
        @review_session.email.should_not == @new_email
        FakeWeb.register_uri :put, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/review_sessions/#{@review_session.uuid}.json", {:body => %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"#{@review_session.uuid}","token":"#{@review_session.token}","url":"https://sandbox.api.paperlex.com/v1/contracts/ce883764523af12e/review?token=71fcd58ed9735cad","email":"#{@new_email}"}} }
        @new_review_session = @contract.update_review_session(@identifier, {:email => @new_email})
        @new_review_session.email.should == @new_email
        @contract.review_sessions.should include(@new_review_session)
        @contract.review_sessions.should_not include(@review_session)
      end
    end

    context "when provided a uuid" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session.uuid
      end
      it_should_behave_like "successful review_session update"
    end

    context "when provided a review_session" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session
      end
      it_should_behave_like "successful review_session update"
    end
  end

  describe "#delete_review_session" do
    before do
      @contract = create_contract
      @contract.create_review_session(:email => Faker::Internet.email)
    end

    shared_examples_for "successful review_session delete" do
      it "should delete the review_session" do
        @review_session = @contract.review_sessions.first
        FakeWeb.register_uri :delete, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/review_sessions/#{@review_session.uuid}.json", {:body => %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"#{@review_session.uuid}","token":"#{@review_session.token}","url":"https://sandbox.api.paperlex.com/v1/contracts/ce883764523af12e/review?token=71fcd58ed9735cad","email":"#{@review_session.email}"}} }
        @contract.delete_review_session(@identifier)
        @contract.review_sessions.should_not include(@review_session)
        @contract.review_sessions.should be_empty
      end
    end

    context "when provided a uuid" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session.uuid
      end
      it_should_behave_like "successful review_session delete"
    end

    context "when provided a review_session" do
      before do
        @review_session = @contract.review_sessions.first
        @identifier = @review_session
      end
      it_should_behave_like "successful review_session delete"
    end
  end

  describe "#versions" do
    before do
      @contract = create_contract
    end

    it "should return details of the various versions of the contract" do
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/versions.json?token=", :body => %{[{"version":1,"event":"update"},{"version":2,"event":"update"},{"version":3,"event":"update"}]}
      versions = @contract.versions
      versions.size.should == 3
      versions.each do |version|
        version.should be_an_instance_of(Paperlex::Version)
        version.version.should be_present
        version.event.should be_present
      end
    end
  end

  describe "#at_version" do
    before do
      @contract = create_contract
    end

    it "should return the given version of the contract" do
      @version_index = 1
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/versions/#{@version_index}.json?token=", :body => %{{"responses":null,"created_at":"2011-10-04T07:09:01Z","current_version":false,"body":"This Non-Disclosure Agreement (the **Agreement**) is made as of **{{effective_date}}** (the **Effective Date**) by and between **{{party_a}}**, reachable at **{{party_a_address}}**; and **{{party_b}}**","uuid":"ce883764523af12e","updated_at":"2011-10-04T07:09:01Z","subject":"NDA","number_of_signers":2,"number_of_identity_verifications":1}}
      contract_version = @contract.version_at(@version_index)
      contract_version.current_version.should be_false
      contract_version.body.should be_present
      contract_version.subject.should be_present
      contract_version.number_of_signers.should be_present
      contract_version.created_at.should be_present
    end
  end

  describe "#revert_to_version" do
    before do
      @contract = create_contract
    end

    it "should return the given version of the contract" do
      @version_index = 1
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/versions/#{@version_index}/revert.json", :body => %{{"responses":null,"created_at":"2011-10-04T07:09:01Z","current_version":false,"body":"This Non-Disclosure Agreement (the **Agreement**) is made as of **{{effective_date}}** (the **Effective Date**) by and between **{{party_a}}**, reachable at **{{party_a_address}}**; and **{{party_b}}**","uuid":"ce883764523af12e","updated_at":"2011-10-04T07:09:01Z","subject":"NDA","number_of_signers":2,"number_of_identity_verifications":1}}
      contract_version = @contract.revert_to_version(@version_index)
      contract_version.current_version.should be_false
      contract_version.body.should be_present
      contract_version.subject.should be_present
      contract_version.number_of_signers.should be_present
      contract_version.created_at.should be_present
    end
  end

  describe "#fetch_responses" do
    before do
      @contract = create_contract
    end

    it "should return the responses hash" do
      @contract.responses.should be_empty
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses.json?token=", :body => %{{"party_b":"Jane Smith","confidential_duration":"1 year","party_a":"John Smith"}}
      expected_results = {'party_b' => 'Jane Smith', 'confidential_duration' => '1 year', 'party_a' => 'John Smith'}
      responses = @contract.fetch_responses
      @contract.responses.should == expected_results
      responses.should == expected_results
    end
  end

  describe "#fetch_response" do
    before do
      @contract = create_contract
    end

    it "should return a response value" do
      @contract.responses.should be_empty
      @key = 'party_a'
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses/#{@key}.json?token=", :body => %{["John Smith"]}
      response = @contract.fetch_response(@key)
      response.should == 'John Smith'
      @contract.responses[@key].should == 'John Smith'
    end
  end

  describe "#save_responses" do
    before do
      @contract = create_contract
    end

    it "should post to paperlex" do
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses.json", :body => "{}"
      @contract.save_responses
    end
  end

  describe "#save_response" do
    before do
      @contract = create_contract
      @key = 'party_a'
    end

    it "should put to paperlex" do
      FakeWeb.register_uri :put, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses/#{@key}.json", :body => "{}"
      @contract.save_response(@key)
    end
  end

  describe "#delete_response" do
    before do
      @contract = create_contract
      @key = 'party_a'
      FakeWeb.register_uri :get, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses.json?token=", :body => %{{"party_b":"Jane Smith","confidential_duration":"1 year","party_a":"John Smith"}}
      @contract.fetch_responses
    end

    it "should delete the response" do
      @key = 'party_a'
      @contract.responses.keys.should include(@key)
      FakeWeb.register_uri :delete, "#{Paperlex.base_url}/contracts/#{@contract.uuid}/responses/#{@key}.json", :body => %{["John Smith"]}
      @contract.delete_response(@key)
      @contract.responses.keys.should_not include(@key)
    end
  end
end
