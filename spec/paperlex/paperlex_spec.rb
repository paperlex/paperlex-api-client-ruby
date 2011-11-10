require 'spec_helper'

describe Paperlex do
  describe ".live!" do
    it "should point the base_url to the live api endpoint" do
      Paperlex.base_url.should_not == Paperlex::LIVE_URL
      Paperlex.live!
      Paperlex.base_url.should == Paperlex::LIVE_URL
    end
  end
end
