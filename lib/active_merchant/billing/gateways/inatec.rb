module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class InatecGateway < Gateway
      self.test_url = 'https://www.taurus21.com/pay/'
      self.live_url = 'https://www.taurus21.com/pay/'

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
        add_config_data(post)
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
        post[:signature] = generate_signature(post)
      end

      def generate_signature(post)
        sorted_param_values =  post.map{|k,v| [k.downcase, v]}.sort.map{|a| a[1]}.join("")
        sorted_param_values << options[:secret]
        signature = Digest::SHA1.hexdigest(sorted_param_values).downcase
      end

      def add_customer_data(post, options)
        post[:firstname] = options.fetch(:first_name) {|k| raise KeyError.new("missing parameter: #{k}")}
        post[:lastname] = options.fetch(:last_name) {|k| raise KeyError.new("missing parameter: #{k}")}
        post[:email] = options.fetch(:email) {|k| raise KeyError.new("missing parameter: #{k}")}
        post[:customerip] = options.fetch(:ip) {|k| raise KeyError.new("missing parameter: #{k}")}
      end

      def add_address(post, creditcard, options)
        post[:street] = options.fetch(:address, {}).fetch(:street) {|k| raise KeyError.new("missing parameter in address: #{k}")}
        post[:zip] = options.fetch(:address, {}).fetch(:zip) {|k| raise KeyError.new("missing parameter in address: #{k}")}
        post[:city] = options.fetch(:address, {}).fetch(:city) {|k| raise KeyError.new("missing parameter in address: #{k}")}
        post[:country] = options.fetch(:address, {}).fetch(:country) {|k| raise KeyError.new("missing parameter in address: #{k}")}
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
        post[:payment_method] = 1 || options[:payment_method]
        post[:orderid] = options.fetch(:order_id) {|k| raise KeyError.new("missing parameter: #{k}")}
      end

      def add_payment(post, payment)
        post[:ccn] = payment.number
        post[:exp_month] = payment.month
        post[:exp_year] = payment.year
        post[:cvc_code] = payment.verification_value
        post[:cardholder_name] = "#{payment.first_name} #{payment.last_name}"
      end

      def commit(action, parameters)
        response = parse(ssl_post(combine_url(action),encode_parameters(parameters)))
        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          test: test?
        )
      end

      def parse(body)
        CGI::parse(body)
      end

      def combine_url(action, parameters = {})
        url = (test? ? test_url : live_url)
        "#{url}#{action}"
      end

      def encode_parameters(parameters)
        URI.encode_www_form(parameters)
      end

      def success_from(response)
        %w(0 2000).include?(response["status"][0])
      end

      def message_from(response)

      end

      def authorization_from(response)

      end
    end
  end
end
