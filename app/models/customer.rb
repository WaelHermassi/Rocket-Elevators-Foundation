class Customer < ApplicationRecord
  has_many :buildings
  belongs_to :user, dependent: :destroy
  belongs_to :address, dependent: :destroy

  after_create :archive_file_to_dropbox

  private

  def archive_file_to_dropbox
    new_cust_has_lead = Lead.where(email: self.email_of_the_company_contact).exists?
    if new_cust_has_lead
      lead_ids = Lead.where(email: self.email_of_the_company_contact).ids
      lead_ids.each do |lead_id|
          @lead = Lead.find(lead_id)
          if @lead.attached_file_stored_as_binary.attached?
            attachment = @lead.attached_file_stored_as_binary.attachment
            blob_data = @lead.attached_file_stored_as_binary.blob
            blob_path = blob_data.service.path_for(blob_data.key)
            client = DropboxApi::Client.new
            folder_exists = client.search("#{@lead.full_name}").matches[0]
            client.create_folder("/#{@lead.full_name}") unless folder_exists
            file_path = "/#{@lead.full_name}/#{blob_data.filename.sanitized}"
            response = client.upload(file_path, blob_data.download)
            attachment.purge if response.id
          end
      end
    end
  end

end