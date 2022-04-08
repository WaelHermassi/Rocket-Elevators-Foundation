# Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
#     puts "--------------------- hello #{user} ---------------------"
#     Rails.logger.info "--------------------- hello #{user.first_name} ---------------------"
#     if Employee.where(user_id: user.id).exists?
#         text = "Greetings #{user.first_name}. There are currently #{Elevator.all.count} elevators deployed in the #{Building.all.count} buildings of your #{Customer.all.count} customers. Currently, #{Elevator.where(status: "Intervention").count} are not in Running Status and are being serviced. You currently have #{Quote.all.count} awaiting for processing and #{Lead.where(date_of_contact_request: nil).count} in your contact requests. #{Battery.all.count} batteries are deployed accross #{Address.where(entity: "building").distinct.count(:city)} cities"
#         client = Aws::Polly::Client.new
#         resp = client.synthesize_speech({output_format: "mp3", sample_rate: "8000", text: text, text_type: "text", voice_id: "Russell",})
#         audio = resp.audio_stream
#         IO.copy_stream(audio, "app/assets/audio/greetings.mp3") 
#         # Rails.logger.info "--------------------- new audio file generated for user #{user.first_name} ---------------------"
#         puts "--------------------- new audio file generated for user #{user.first_name} ---------------------"

#     end
# end