class TicketFd
    def initialize(intervention)
        @intervention = intervention

    end
    def sendticket
        require 'net/http'
        require 'uri'
        require 'json'
        
        uri = URI.parse("https://rocketelevatorwael.freshdesk.com/api/v2/tickets")
        api_key = ENV['FRESHDESK_API']
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(api_key, "X")
        puts api_key
        puts "hahahahahahahahahahahahahaha"
        request.content_type = "application/json"
        msg = "Hello here is the data entred in the intervention: AuthoId:  #{@intervention.author}, compagny  with id : #{@intervention.customer_id} , BuildingId: #{@intervention.building_id},BatteryId: #{@intervention.battery_id}, columnId: #{@intervention.column_id}, elevatorId: #{@intervention.elevator_id}, employeeId :#{@intervention.employee_id}, and the raport: #{@intervention.report}  "
        request.body = JSON.dump({
          "description" => msg,
          "subject" =>"Bonjour",
          "email" => "r.r@gmail.com",
          "priority" => 1,
          "status" => 2,
          
        })
        req_options = {
          use_ssl: uri.scheme == "https",
        }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
            end
    end    
end     