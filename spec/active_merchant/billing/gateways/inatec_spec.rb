require "spec_helper"
require "pry"

describe ActiveMerchant::Billing::InatecGateway do
  let(:credentials) do
    {
      :merchant_id => "",
      :secret => ""
    }
  end
  let(:options) do
    {
      :currency => 'EUR',
      :description => 'ActiveMerchant Test Purchase',
      :email => 'wow@example.com',
    }
  end

  let(:amount) {100}

  subject do
    ActiveMerchant::Billing::InatecGateway.new(credentials)
  end

  it "captures funds" do
    subject.purchase(amount, credit_card, options)
  end
end

def credit_card(number = '4242424242424242', options = {})
  defaults = {
    :number => number,
    :month => 9,
    :year => Time.now.year + 1,
    :first_name => 'Longbob',
    :last_name => 'Longsen',
    :verification_value => '123',
    :brand => 'visa'
  }.update(options)

  ActiveMerchant::Billing::CreditCard.new(defaults)
end

def setup
  @gateway = StripeGateway.new(fixtures(:stripe))
  @currency = fixtures(:stripe)["currency"]
  # You may have to update the currency, depending on your tenant
  @credit_card = credit_card('4242424242424242')

  @options = {
    :currency => @currency,
    :description => 'ActiveMerchant Test Purchase',
    :email => 'wow@example.com'
  }
end

def test_successful_purchase
  assert response = @gateway.purchase(@amount, @credit_card, @options)
  assert_success response
  assert_equal "charge", response.params["object"]
  assert response.params["paid"]
  assert_equal "ActiveMerchant Test Purchase", response.params["description"]
  assert_equal "wow@example.com", response.params["metadata"]["email"]
end
