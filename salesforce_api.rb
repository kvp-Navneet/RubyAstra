class SalesforceApi < ApplicationRecord
  include HTTParty
  def self.connect_to_salesforce(to_log = true)
    Restforce.log = to_log
    client = Restforce.new(
      :username       => ENV['SALESFORCE_USERNAME'],
      :password       => ENV['SALESFORCE_PASSWORD'],
      :security_token => ENV['SALESFORCE_SECURITY_TOKEN'],
      :client_id      => ENV['SALESFORCE_CLIENT_ID'],
      :client_secret  => ENV['SALESFORCE_CLIENT_SECRET'],
      :host           => ENV['SALESFORCE_HOST']
	  	)
    client.authenticate!
    oauth_token = client.instance_variable_get(:@options)[:oauth_token]
    instance_url = client.instance_variable_get(:@options)[:instance_url]
    [oauth_token, instance_url]
  end
  def self.post_to_salesforce(custom_url,params_body)
    if SalesforceApi.last.present?
      con = SalesforceApi.last
    else
      res = connect_to_salesforce
      con = SalesforceApi.create(access_token: res[0], instance_url: res[1])
    end
    url = "#{con.instance_url}#{custom_url}"
    headers = { "Authorization" => "OAuth #{con.access_token}", "Content-Type" => 'application/json'}
    begin
      response = HTTParty.post(url, :body => params_body.to_json, :headers => headers)
      end
    rescue Net::ReadTimeout
      nil
    end
    unless response.nil?
      if response[0].present? && response[0]["errorCode"] == "INVALID_SESSION_ID" 
        res = connect_to_salesforce
        SalesforceApi.last.update(access_token: res[0], instance_url: res[1])
        post_to_salesforce(custom_url, params_body)
      else
        response
      end
    end
  end
end
