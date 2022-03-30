json.extract! lead, :id, :full_name, :company_name, :email, :phone, :project_name, :project_description, :department_in_charge_of_elevators, :message, :attached_file_stored_as_binary, :date_of_contact_request, :created_at, :updated_at
json.url lead_url(lead, format: :json)
