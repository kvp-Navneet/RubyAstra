class Account < ApplicationRecord
  after_create :create_record_salesforce 
  validates :salesforce_id,uniqueness: true
    def create_record_salesforce 
	    exclude_attr =  ["created_at", "updated_at", "salesforce_id"]
	    if self.changes.except(*exclude_attr).present? 
	      AccountWorker.perform_async(self.id, "update")
	    end 
	end
end
