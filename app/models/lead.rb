require 'uri'
require 'net/http'
require 'openssl'

class Lead < ApplicationRecord
    has_one_attached :attached_file_stored_as_binary

    # NOTE: NOTIFY.EU API
    # after_create :send_email

    # def send_email

    #     url = URI("https://notify-eu.p.rapidapi.com/notification/send")

    #     http = Net::HTTP.new(url.host, url.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    #     request = Net::HTTP::Post.new(url)
    #     request["content-type"] = 'application/json'
    #     request["X-ClientId"] = ENV['notify_client_id']
    #     request["X-SecretKey"] = ENV['secret_key']
    #     request["Content-Type"] = 'application/json'
    #     request["X-RapidAPI-Host"] = ENV['Rapid_API_Host']
    #     request["X-RapidAPI-Key"] = ENV['Rapid_API_Key']

    #     request.body = "{
    #         \"message\": {
    #           \"transport\": [
    #             {
    #               \"type\": \"smtp\",
    #               \"subject\": \"\",
    #               \"recipients\": {
    #                 \"to\": [
    #                   {
    #                     \"name\": \"" + self.full_name + "\",
    #                     \"email\": \"" + self.email + "\"
    #                   }
    #                 ]
    #               }
    #             }
    #           ],
    #           \"notificationType\": \"smtp_email\",
    #           \"language\": \"en\",
    #           \"params\": {
    #             \"name\": \"" + self.full_name + "\",
    #             \"project_name\": \"" + self.project_name + "\"
    #           }
    #         }
    #       }"
          
        
    #     response = http.request(request)
    #     puts response.read_body

    # end
end
