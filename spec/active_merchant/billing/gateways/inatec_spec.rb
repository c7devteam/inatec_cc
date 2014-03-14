require "spec_helper"
require "pry"

describe ActiveMerchant::Billing::InatecGateway do
  subject do
    described_class.new({merchant_id: "merch_id", secret: "secret"})
  end

  it "initializes" do
    subject
  end

  it "captures funds" do
    binding.pry
    subject.purchase(10,:money,:woo)
  end
end
