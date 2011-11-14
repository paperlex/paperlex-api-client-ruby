require 'spec_helper'

describe Paperlex::ReviewSession do
  before do
    @contract_uuid = "4776f3b030afa70d"
    @email = Faker::Internet.email

    unless Paperlex.token
      FakeWeb.register_uri :post, "#{Paperlex.base_url}/contracts/#{@contract_uuid}/review_sessions.json", :body => %{{"expires_at":"2011-10-05T07:10:03Z","uuid":"d9df3765905e7695","token":"71fcd58ed9735cad","url":":https =>//sandbox.api.paperlex.com/v1/contracts/#{@contract_uuid}/review?token=71fcd58ed9735cad","email":"#{@email}"}}
    end
  end

  describe ".create" do
    context "with simple parameters" do
      before do
        @review_session = Paperlex::ReviewSession.create("contract_uuid" => @contract_uuid,"email" => @email)
      end

      it "should create a review session" do
        @review_session.expires_at.should be_present
        @review_session.email.should == @email
        @review_session.uuid.should be_present
        @review_session.url.should be_present
        @review_session.token.should be_present
        @review_session.contract_uuid.should == @contract_uuid
      end
    end
  end
end
