require 'spec_helper'

describe Paperlex::Contract do
  before do
    @body = Faker::Lorem.paragraphs.join("\n\n")
    @subject = Faker::Company.catch_phrase

    unless ENV['TEST_API']
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts.json", body: "{\"locked\":false,\"responses\":null,\"created_at\":\"2011-10-27T23:28:31Z\",\"body\":\"#{@body.gsub("\n", '\n')}\",\"current_version\":true,\"uuid\":\"4776f3b030afa70d\",\"updated_at\":\"2011-10-27T23:28:31Z\",\"number_of_identity_verifications\":1,\"subject\":\"#{@subject}\",\"number_of_signers\":2,\"signers\":[],\"signatures\":[]}"
    end
  end

  describe ".create" do
    it "should return a contract object" do
      contract = Paperlex::Contract.create({"body" => @body,"subject" => @subject,"number_of_signers" => 2})
      contract.number_of_signers.should == 2
      contract.subject.should == @subject
      contract.body.should == @body
      contract.signers.should be_empty
      contract.signatures.should be_empty
      contract.current_version.should == true
      contract.uuid.should be_present
      contract.updated_at.should be_present
      contract.created_at.should be_present
    end
  end
end
