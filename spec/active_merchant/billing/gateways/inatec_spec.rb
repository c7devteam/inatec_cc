require 'spec_helper'

describe ActiveMerchant::Billing::InatecGateway do
  before do
    ActiveMerchant::Billing::Base.mode = :test
  end

  # Preauthorize
  # 
  # Capture
  # 
  let(:credit_card) do
    defaults = {
      number: "5232050000010003",
      month: 12,
      year: Time.local(2014).year,
      first_name: 'Muster',
      last_name: 'Mann',
      verification_value: '003',
      brand: 'master_card'
    }
    ActiveMerchant::Billing::CreditCard.new(defaults)
  end

  let(:options) do
    {
      order_id: '1',
      ip: '10.0.0.1',
      first_name: 'Muster',
      last_name: 'Mann',
      description: 'ActiveMerchant Test Purchase',
      email: 'wow@example.com',
      currency: 'EUR',
      recurring_id: '123',
      address: {
        zip: '3301',
        street: 'Grants street',
        city: 'Kuldiga',
        country: 'LVA'
      }
    }
  end

  let(:credentials) do
    path = File.join("spec", "fixtures", "credentials.yml")
    creds = YAML.load(File.read(path))
    { merchant_id: '21', secret: '123' } # Gateway works with symbols
  end

  let(:amount) { 123 }

  subject do
    ActiveMerchant::Billing::InatecGateway.new(credentials)
  end

  describe "Authorize" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_authorize")
        .to_return(status: 200, body: "transactionid=43327070&transid=43327070&status=0&errormessage=&errmsg=&amount=1.23&price=1.23&currency=EUR&orderid=1&user_id=7462847")
    end
    it "Creates a authorize request" do
      response = subject.authorize(amount, credit_card, options)
      expect(response).to be_success
      expect(response).to be_test
    end
  end

  describe "Authorize with recurring" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_authorize")
        .to_return(status: 200, body: "transactionid=43327070&transid=43327070&status=0&errormessage=&errmsg=&amount=1.23&price=1.23&currency=EUR&orderid=1&user_id=7462847")
    end
    it "Creates a authorize request" do
      response = subject.authorize_with_recurring(amount, credit_card, options)
      expect(response).to be_success
      expect(response).to be_test
    end
  end

  describe "Pre authorize" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_preauthorize")
        .to_return(status: 200, body: "transactionid=43327070&transid=43327070&status=0&errormessage=&errmsg=&amount=1.23&price=1.23&currency=EUR&orderid=1&user_id=7462847")
    end

    it "Preauthorizes payment" do
      response = subject.preauthorize(amount, credit_card, options)
      expect(response).to be_success
      expect(response).to be_test
    end
  end

  describe "Capture" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_capture")
        .to_return(status: 200, body: "transactionid=43328376&transid=43328376&status=0&errormessage=&errmsg=&amount=1.23&price=1.23&currency=EUR&orderid=1")
    end

    it "captures preauthorized payment" do
      response = subject.capture({ transaction_id: "12312312" })
      expect(response).to be_success
      expect(response).to be_test
    end
  end

  describe "Payment refund" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_refund")
        .to_return(status: 200, body: "transactionid=43328589&transid=43328589&status=0&errormessage=&errmsg=&amount=1.23&price=1.23&currency=EUR&orderid=1")
    end

    it "captures payment" do
      response = subject.refund(amount, { transaction_id: "43328589" })
      expect(response).to be_success
      expect(response).to be_test
    end
  end

  describe "Errors in parameters" do
    before do
      stub_request(:post, "https://www.taurus21.com/pay/backoffice/payment_refund")
        .to_return(status: 200, body: "transactionid=&transid=&status=101&errormessage=Some+Bad+Stuff+Happened&errmsg=&amount=&currency=EUR&orderid=")
    end

    it "captures payment" do
      response = subject.refund(amount, { transaction_id: "43328589" })
      expect(response).not_to be_success
      expect(response).to be_test
      expect(response.message).to eq("Some Bad Stuff Happened")
    end
  end
end
