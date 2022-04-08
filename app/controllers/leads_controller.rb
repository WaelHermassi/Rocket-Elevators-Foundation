class LeadsController < ApplicationController
  
  before_action :set_lead, only: %i[ show edit update destroy ]

    # GET /leads or /leads.json
  def index
    @leads = Lead.all
  end

  # GET /leads/1 or /leads/1.json
  def show
    @lead = Lead.find(params[:id])
  end

  # GET /leads/new
  def new
    @lead = Lead.new
  end

  # GET /leads/1/edit
  def edit
  end

  # POST /leads or /leads.json
  def create
    puts "create lead function works ---------------------------------------------"
    @post = Post.new(post_params)
    if NewGoogleRecaptcha.human?(
        params[:new_google_recaptcha_token],
        "checkout",
        NewGoogleRecaptcha.minimum_score,
        @post
      ) && @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end
  
  def create
    puts "create lead function works ---------------------------------------------"
    @lead = Lead.new(lead_params)

    my_uri = "https://#{ENV['FRESHDESK_DOMAIN']}.freshdesk.com/api/v2/tickets"
    my_key = ENV['FRESHDESK_API_KEY']

    respond_to do |format|
      if @lead.save
        format.html { redirect_to "/", notice: "Thank you. We will communicate with you shortly!" }
        format.json { render :show, status: :created, location: @lead }

        attachment_exists = @lead.attached_file_stored_as_binary.attached?
        user_is_customer = Customer.where(email_of_the_company_contact: "#{@lead.email}").present? || Customer.where(technical_manager_email_for_service: "#{@lead.email}").present?
        site = RestClient::Resource.new(my_uri, my_key, 'X')
        # client = RestClient::Resource.new

        if attachment_exists
          
          attachment = @lead.attached_file_stored_as_binary.attachment
          blob_data = @lead.attached_file_stored_as_binary.blob
          blob_path = blob_data.service.path_for(blob_data.key)
          
          # NOTE: FRESHDESK
          data_hash = {
              status: 2,
              priority: 1,
              subject: "#{@lead.full_name} from #{@lead.company_name}", 
              description: "The contact #{@lead.full_name}  from company #{@lead.company_name} can be reached at email #{@lead.email} and at phone number #{@lead.phone}. #{@lead.department_in_charge_of_elevators} has a project named #{@lead.project_name} which would require contribution from Rocket Elevators.\nProject Description: #{@lead.project_description}\n#{@lead.message}.\nThe Contact uploaded an attachment",
              email: "#{@lead.email}",
              type:"Question",
              custom_fields: {
                  "cf_comment": "The contact #{@lead.full_name}  from company #{@lead.company_name} can be reached at email #{@lead.email} and at phone number #{@lead.phone}. #{@lead.department_in_charge_of_elevators} has a project named #{@lead.project_name} which would require contribution from Rocket Elevators.\nProject Description: #{@lead.project_description}",
                  "cf_attached_message": "#{@lead.message}"
              },
              attachments: [File.new(blob_path, "rb")]
            }

            # data_json = JSON.generate(data_hash)
            site.post(data_hash)

            if user_is_customer
              # NOTE: DROPBOX
              # authenticator = DropboxApi::Authenticator.new(ENV["DROPBOX_KEY"], ENV["DROPBOX_SECRET"])
              # authenticator.auth_code.authorize_url(token_access_type: "offline")
              # access_token = authenticator.auth_code.get_token(ENV["DROPBOX_ACCESS_CODE"])
              # client = DropboxApi::Client.new(access_token: access_token)
              client = DropboxApi::Client.new
              folder_exists = client.search("#{@lead.full_name}").matches[0]
              client.create_folder("/#{@lead.full_name}") unless folder_exists
              file_path = "/#{@lead.full_name}/#{blob_data.filename.sanitized}"
              response = client.upload(file_path, blob_data.download)
              attachment.purge if response.id
            end
          
        else
          # attachment does not exist or user is not customer 
          data_hash = {
            status: 2,
            priority: 1,
            subject: "#{@lead.full_name} from #{@lead.company_name}", 
            description: "The contact #{@lead.full_name}  from company #{@lead.company_name} can be reached at email #{@lead.email} and at phone number #{@lead.phone}. #{@lead.department_in_charge_of_elevators} has a project named #{@lead.project_name} which would require contribution from Rocket Elevators.\nProject Description: #{@lead.project_description}\n#{@lead.message}.\nThe Contact uploaded an attachment",
            email: "#{@lead.email}",
            type:"Question",
            custom_fields: {
                "cf_comment": "The contact #{@lead.full_name}  from company #{@lead.company_name} can be reached at email #{@lead.email} and at phone number #{@lead.phone}. #{@lead.department_in_charge_of_elevators} has a project named #{@lead.project_name} which would require contribution from Rocket Elevators.\nProject Description: #{@lead.project_description}",
                "cf_attached_message": "#{@lead.message}"
            }
          }
          
          data_json = JSON.generate(data_hash)
          # site.post(data_json)
          RestClient::Request.execute(
            method: :post,
            url: my_uri,
            user: my_key,
            password: 'X',
            payload: data_json,
            headers: {"Content-Type" => "application/json"},
          )

        end

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leads/1 or /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params)
        format.html { redirect_to lead_url(@lead), notice: "Lead was successfully updated." }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1 or /leads/1.json
  def destroy
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to leads_url, notice: "Lead was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead
      @lead = Lead.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lead_params
      params.permit(:full_name, :company_name, :email, :phone, :project_name, :project_description, :department_in_charge_of_elevators, :message, :attached_file_stored_as_binary)
    end

end
