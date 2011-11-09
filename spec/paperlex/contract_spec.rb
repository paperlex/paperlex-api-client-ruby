require 'spec_helper'

describe Paperlex::Contract do
  before do
    @contract_uuid = "4776f3b030afa70d"
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @subject = Faker::Company.catch_phrase

    unless Paperlex.token
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts.json", body: "{\"locked\":false,\"responses\":null,\"created_at\":\"2011-10-27T23:28:31Z\",\"body\":\"#{@body.gsub("\n", '\n')}\",\"current_version\":true,\"uuid\":\"#{@contract_uuid}\",\"updated_at\":\"2011-10-27T23:28:31Z\",\"number_of_identity_verifications\":1,\"subject\":\"#{@subject}\",\"number_of_signers\":2,\"signers\":[],\"signatures\":[]}"
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
        unless Paperlex.token
          FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract_uuid}/signers.json", body: "{\"uuid\":\"3ab109b11a083b31\",\"email\":\"janesmith@example.com\"}"
        end

        @signers = [Faker::Internet.email, Faker::Internet.email]
        @contract = Paperlex::Contract.create("body" => @body, "subject" => @subject, "number_of_signers" => 2, 'signers' => @signers)
      end

      it_should_behave_like "contract creation"

      it "should create signers" do
        @contract.signers.should_not be_empty
        @contract.signatures.should be_empty
      end
    end
  end
end
