require "spec_helper"
require "pry"

describe ActiveMerchant::Billing::InatecGateway do
  let(:credit_card) do
    defaults = {
      number: "5232050000010003",
      month: 12,
      year: Time.now.year,
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
      first_name: "Muster",
      last_name: "Mann",
      description: 'ActiveMerchant Test Purchase',
      email: 'wow@example.com',
      currency: "EUR",
      address: {
        zip: '3301',
        street: "Grants street",
        city: "Kuldiga",
        country: "LVA"
      }
    }
  end
  let(:credentials) do
    path = Path.join("spec", "fixtures", "credentials.yml")
    YAML.parse(File.read(path))
  end

  let(:amount) {1.00}

  subject do
    ActiveMerchant::Billing::InatecGateway.new(credentials)
  end

  describe "Purchase" do
    it "captures funds" do
      response = subject.purchase(amount, credit_card, options)
      expect(response).to be_success
      expect(response).to be_test
    end
  end

end
