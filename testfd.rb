require 'net/http'
      require 'uri'
      require 'json'
      uri = URI.parse("https://rocketelevatorwael.freshdesk.com/api/v2/tickets")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth("xxertKyNaaj3JuVX8Zp", "X")
      request.content_type = "application/json"
      msg = "Msg to switch"
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