module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class InatecGateway < Gateway
      self.test_url = 'https://www.taurus21.com/pay'
      self.live_url = 'https://www.taurus21.com/pay'

      #self.supported_countries = ['US']
      self.default_currency = 'EUR'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'http://www.inatec.com'
      self.display_name = 'Inatec'

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

      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('backoffice/payment_authorize', post)
      end

      def capture(money, authorization, options={})
        commit('backoffice/payment_capture', post)
      end

      def refund(money, authorization, options={})
        commit('backoffice/payment_refund', post)
      end

      def void(authorization, options={})
        commit('void', post)
      end

      private

      def add_config_data(post)
        post[:merchantid] = options[:merchant_id]
        post[:signiture] = generate_signature(post)
      end

      def generate_signature(post)
        sorted_param_values = post.sort.map {|k,v| v}.join
        signature = Digest::SHA1.hexdigest(sorted_param_values + options[:secret]).downcase
      end

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
        post[:paymeny_method] = 1 
        post[:"Orderid"] = 1

      end

      def add_payment(post, payment)
        post[:ccn] = payment.number
        post[:exp_month] = payment.month
        post[:exp_year] = payment.year
        post[:cvc_code] = payment.verification_value
        post[:cardholder_name] = "#{payment.first_name} #{payment.last_name}"
      end


      def parse(body)
        {}
      end

      def commit(action, parameters)
        response = parse(ssl_post(combine_url(action, parameters), ""))
        binding.pry
        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def combine_url(action, parameters = {})
        url = (test? ? test_url : live_url)
        encoded_params = URI.encode_www_form(parameters)
        uri = URI("#{url}#{action}?#{encoded_params}")
        puts uri
        uri
      end

      def encode_parameters(parameters)

      end

    end
  end
end
