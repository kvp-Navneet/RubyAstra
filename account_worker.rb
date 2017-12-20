require 'sidekiq'
require 'sidekiq/testing/inline'
class AccountWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3
  def perform(account_id, action=nil,step)
    account = Account.find_by_id(account_id)
    account = account.student_application.student_account
    custom_url = "/services/apexrest/CustomApi/*"
    if action == "update" 
      params_body = payment_confirmation(account)
    end
    response = SalesforceApi.post_to_salesforce(custom_url, params_body)
    #########UPDATE######################
    if response[0]["Id"].present?
       account.update(:salesforce_id=>response[0]["Id"])
    else
      p "==================response from salesforce=================================="
      p response.to_s
      p "==================response from salesforce=================================="
    end
    ############END######################
  end
end

private
  def payment_confirmation(account)
    {
      :"accountRecord" => [{
          :"name"=> account.try(:name),
          :"age"=> account.try(:age),
          :"address"=> account.try(:address)
      }]
    }
  
  end
