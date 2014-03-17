# ActiveMerchant Inatec Gateway

Active Merchant inatec payment gateway. 

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
    # Purchase
    def initialize(options={})
      requires!(options, :merchant_id, :secret)
      super
    end
  
    def purchase(money, payment, options={})
      post = {}
      add_invoice(post, money, options)
      add_payment(post, payment)
      add_address(post, payment, options)
      add_customer_data(post, options)
      add_config_data(post)
      commit('backoffice/payment_authorize', post)
    end
  
    def capture(options={})
      post = {}
      add_capture_params(post, options)
      add_config_data(post)
      commit('backoffice/payment_capture', post)
    end
  
    def authorize(money, payment, options={})
      post = {}
      add_invoice(post, money, options)
      add_payment(post, payment)
      add_address(post, payment, options)
      add_customer_data(post, options)
      add_config_data(post)
      commit('backoffice/payment_preauthorize', post)
    end
  
  
    def refund(money, options={})
      post = {}
      add_refund_params(post, money, options)
      add_config_data(post)
      commit('backoffice/payment_refund', post)
    end




# Create a new credit card object

## Contributing

1. Fork it (https://github.com/c7devteam/inatec_cc)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
