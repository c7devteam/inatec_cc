# ActiveMerchant Inatec Gateway

Active Merchant Inatec payment gateway. http://inatec.com/ 

## Installation

Add this line to your application's Gemfile:

    gem 'active_merchant_inatec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_merchant_inatec

## Usage

Please refer to https://github.com/Shopify/active_merchant to understand basic active merchant flow.

Inatec specific methods:

```ruby

# This gem is using active merchants built in credit card DTO

credit_card = 
    ActiveMerchant::Billing::CreditCard.new({
      number: "5232051231210003",
      month: 12,
      year: Time.local(2014).year,
      first_name: 'Muster',
      last_name: 'Mann',
      verification_value: '003',
      brand: 'master_card'
    })

# To initialize inatec gateway, you need to pass merchant id (Payment id in credentials 
# document provided by inatec) and secret

gw = ActiveMerchant::Billing::InatecGateway.new(merchant_id: "your_merch_id", secret: "your_secret")

# The Authorize request will send an authorization request to the authorization system, which will verify the
# credit card data and credit line. If the request is verified, the credit card will be charged immediately.

amount = 100 # cents

# All these values are mandatory
options = {
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

# To make a authorize request you will need to pass amount in cents, active merchants
# credit card class instance and options as seen above with your values. 
gw.authorize(amount, credit_card, options)

# The Preauthorize request will send an authorization request to the authorization system, which will verifythe
# credit card data, credit line, and reserve the requested amount. 

# Preauthorize uses the same parameters as authorize requests
gw.preauthorize(amount, credit_card, options)


# The Capture request follows a successful Preauthorize request. The request will send an authorization request
# to the authorization system, which will book the amount previously reserved by the Preauthorize request and
# the customer’s credit card will then be charged. 

# Capture requires transaction id to complete book amount
gw.capture(transaction_id: "123456")

# Refund requires transaction id and amount in cents to refund purchase
gw.refund(transaction_id: "123456", amount: 123 )

```

## Contributing

1. Fork it (https://github.com/c7devteam/inatec_cc)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
