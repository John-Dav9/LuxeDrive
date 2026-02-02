class PaypalCheckout
  API_BASE = {
    "sandbox" => "https://api-m.sandbox.paypal.com",
    "production" => "https://api-m.paypal.com"
  }.freeze

  def self.create_order(booking)
    token = access_token
    return {} unless token

    amount = format("%.2f", booking.total_price)
    body = {
      intent: "CAPTURE",
      purchase_units: [
        {
          amount: {
            currency_code: "EUR",
            value: amount
          },
          custom_id: "booking_#{booking.id}"
        }
      ]
    }

    request("/v2/checkout/orders", token, body)
  end

  def self.capture_order(order_id)
    token = access_token
    return {} unless token

    request("/v2/checkout/orders/#{order_id}/capture", token, {}, :post)
  end

  def self.access_token
    client_id = ENV["PAYPAL_CLIENT_ID"]
    secret = ENV["PAYPAL_CLIENT_SECRET"]
    return nil if client_id.blank? || secret.blank?

    uri = URI("#{api_base}/v1/oauth2/token")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(client_id, secret)
    req.set_form_data({ grant_type: "client_credentials" })

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    json = JSON.parse(res.body)
    json["access_token"]
  rescue StandardError
    nil
  end

  def self.request(path, token, payload = {}, method = :post)
    uri = URI("#{api_base}#{path}")
    req = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{token}"
    req.body = payload.to_json if payload.present?

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(res.body)
  rescue StandardError
    {}
  end

  def self.verify_webhook?(headers, payload)
    webhook_id = ENV["PAYPAL_WEBHOOK_ID"]
    return false if webhook_id.blank?

    token = access_token
    return false unless token

    body = {
      auth_algo: headers["PAYPAL-AUTH-ALGO"],
      cert_url: headers["PAYPAL-CERT-URL"],
      transmission_id: headers["PAYPAL-TRANSMISSION-ID"],
      transmission_sig: headers["PAYPAL-TRANSMISSION-SIG"],
      transmission_time: headers["PAYPAL-TRANSMISSION-TIME"],
      webhook_id: webhook_id,
      webhook_event: JSON.parse(payload)
    }

    res = request("/v1/notifications/verify-webhook-signature", token, body)
    res["verification_status"] == "SUCCESS"
  rescue StandardError
    false
  end

  def self.api_base
    API_BASE.fetch(ENV.fetch("PAYPAL_MODE", "sandbox"), API_BASE["sandbox"])
  end
end
