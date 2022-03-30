require 'pg'

#databasename: foobarwarehouse
#host: codeboxx-postgresql.cq6zrczewpu2.us-east-1.rds.amazonaws.com

desc "Create data warehouse for facts and dimensions."

month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

host_name = ENV['CODEBOXX_HOST']
user_name = ENV['CODEBOXX_USER']
pwd = ENV['CODEBOXX_PWD']

namespace :warehouse do

    task :create_quoteFact, [:db_name] do |task, args|
        puts "connected to #{args[:db_name]}"

        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        conn.exec("CREATE TABLE IF NOT EXISTS quote_fact (
            id SERIAL PRIMARY KEY,
            company_name VARCHAR(50) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            num_elev INTEGER NOT NULL,
            created_at TIMESTAMP NOT NULL
        )");
        puts "...quote_fact table created"
    end

    task :import_quoteFact, [:db_name] => :environment do |task, args|        
        puts "Connected to #{args[:db_name]}"

        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        count = 0
        Quote.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |quote|
            quote.company_name.sub! '\'', '"'
            conn.exec("INSERT INTO quote_fact (id, company_name, email, num_elev, created_at) VALUES ('#{quote.id}', '#{quote.company_name}', '#{quote.email}', '#{quote.num_elev}', '#{quote.created_at}')")
            count += 1
        end
        puts "... a total of quote form records #{count} was saved to data warehouse at table: quote_fact."
    end

    ########################################################################
    ########################################################################

    task :create_contactFact, [:db_name] do |task, args|
        puts "connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        conn.exec("CREATE TABLE IF NOT EXISTS contact_fact (
            id SERIAL PRIMARY KEY,
            company_name VARCHAR(50) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            project_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP NOT NULL
        )");
        puts "...contact_fact table created."
    end

    task :import_contactFact, [:db_name] => :environment do |task, args|        
        puts "Connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")
        
        count = 0
        Lead.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |lead|

            lead.company_name.sub! '\'', '"'
            lead.project_name.sub! '\'', '"'

            conn.exec("INSERT INTO contact_fact (id, company_name, email, project_name, created_at) VALUES ('#{lead.id}', '#{lead.company_name}', '#{lead.email}', '#{lead.project_name}', '#{lead.created_at}')")
            count += 1
        end  
        puts "... a total of #{count} leads was saved to data warehouse at table: contact_fact."
    end

    ########################################################################
    ########################################################################

    task :create_elevFact, [:db_name] do |task, args|
        puts "connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")
        
        conn.exec("CREATE TABLE IF NOT EXISTS elevator_fact (
            id SERIAL PRIMARY KEY,
            serial_number VARCHAR(255) NOT NULL,
            commission_date TIMESTAMP NOT NULL,
            building_id INTEGER NOT NULL,
            customer_id INTEGER NOT NULL,
            building_city VARCHAR(50) NOT NULL
        )")
    end

    task :import_elevFact, [:db_name] => :environment do |task, args|        
        puts "Connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        count = 0
        Elevator.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |elevator|
            
            # elevator_id > column_id > battery_id > building_id > customer_id 
            building_id = Battery.find(Column.find(elevator.column_id).battery_id).building_id
            # customer_id
            customer_id = Building.find(building_id).customer_id
            city = Address.find(Building.find(building_id).address_id).city

            if city 
                city.sub! '\'', '"'
            end

            conn.exec("INSERT INTO elevator_fact (id, serial_number, commission_date, building_id, customer_id, building_city) VALUES ('#{elevator.id}', '#{elevator.serial_number}', '#{elevator.date_of_commissioning}', '#{building_id}', '#{customer_id}', '#{city}')")
            count += 1
        end
        puts "... a total of #{count} elevator data was saved to warehouse at table: elevator_fact."
    end

    ########################################################################
    ######################################################################## 

    task :create_dimCustomer, [:db_name] do |task, args|
        puts "connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        conn.exec("CREATE TABLE IF NOT EXISTS dim_customer (
            id SERIAL PRIMARY KEY,
            customer_creation_date TIMESTAMP NOT NULL,
            company_name VARCHAR(50) NOT NULL,
            contact_full_name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            num_elev INTEGER NOT NULL,
            city VARCHAR(50) NOT NULL
        )");
        puts "...dim_customer table created"
    end

    task :import_dimCustomer, [:db_name] => :environment do |task, args|        
        puts "Connected to #{args[:db_name]}..."
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        count = 0
        Customer.where(customer_creation_date: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |customer|
            num_elev = 0
            Elevator.all.each do |elevator|
                if Building.find(Battery.find(Column.find(elevator.column_id).battery_id).building_id).customer_id == customer.id
                    num_elev += 1
                end
            end
            customer.company_name.sub! '\'', '"'
            customer.full_name_of_the_company_contact.sub! '\'', '"'
            conn.exec("INSERT INTO dim_customer (id, customer_creation_date, company_name, contact_full_name, email, city, num_elev) VALUES ('#{customer.id}', '#{customer.customer_creation_date}', '#{customer.company_name}', '#{customer.full_name_of_the_company_contact}', '#{customer.email_of_the_company_contact}', '#{Address.find(customer.address_id).city}', '#{num_elev}')")
            count += 1
        end
        puts "... a total of #{count} customer data was saved to data warehouse at table: dim_customer."
    end
    #############################################################################################################
    #############################################################################################################

    task :create_factIntervention, [:db_name] do |task, args|
        puts "connected to #{args[:db_name]}"
        
        conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        # conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")
        conn.exec("CREATE TABLE IF NOT EXISTS factIntervention (
            id SERIAL PRIMARY KEY,
            employee_id INTEGER NOT NULL,
            building_id INTEGER NOT NULL,
            battery_id INTEGER,
            column_id INTEGER,
            elevator_id INTEGER,
            start_date_time_of_intervention TIMESTAMP NOT NULL,
            end_date_time_of_intervention TIMESTAMP,
            result VARCHAR(255) NOT NULL,
            report VARCHAR(255) NOT NULL,
            status VARCHAR(255) NOT NULL

        )");
        puts "...factIntervention created"
    end
    task :import_factIntervention, [:db_name] => :environment do |task, args|        
        puts "Connected to #{args[:db_name]}"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")
        
        (1..80).each do |i|
            id = i
            employee_id = Faker::Number.between(from: 1, to: 11)
            building_id = Faker::Number.between(from: 1, to: 11)
            battery_id = Faker::Number.between(from: 1, to: 75)
            column_id = Faker::Number.between(from: 1, to: 150)
            elevator_id = Faker::Number.between(from: 1, to: 450)
            start_date_time_of_intervention =  Faker::Time.between(from: DateTime.now - 1, to: DateTime.now, format: :long)
            end_date_time_of_intervention =  Faker::Time.between(from: DateTime.now - 1, to: DateTime.now + 1, format: :long)
            result = ["Success","Failure","Incomplete"].sample
            report = "Let me tell you about my intervention."
            status = ["Pending","InProgress","Interrupted","Resumed","Complete"].sample
            conn.exec("INSERT INTO factIntervention (id,employee_id,building_id,battery_id,column_id,elevator_id,start_date_time_of_intervention,end_date_time_of_intervention,result,report,status) VALUES (#{id},#{employee_id},#{building_id},#{battery_id},#{column_id},#{elevator_id},'#{start_date_time_of_intervention}','#{end_date_time_of_intervention}','#{result}','#{report}','#{status}')")
        end
        end
        puts "... a total of  data was saved to warehouse at table: factIntervention."
end

    ########################################################################
    ######################################################################## 

namespace :query do 

    task :one, [:db_name] => :environment do |task, args|
        curr_year = nil
        # The number of unique requests (ContactId) grouped by Month (Creation Date)
        puts "Query 1: The number of unique requests grouped by Month (2019-2022)"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        puts "-------------+------------------+------------"
        puts "#{"Total Leads".ljust(10)}  | #{"Month".ljust(15)}  | #{"Year".ljust(10)}   "
        puts "-------------+------------------+------------"
        
        conn.exec("SELECT COUNT(id) as total_contact, date_trunc('month', created_at) as month FROM contact_fact GROUP BY date_trunc('month', created_at) ORDER BY date_trunc('month', created_at)").to_a.each do |row|
            year = Date.parse(row["month"]).year
            lead_month = month[Date.parse(row["month"]).mon - 1]
            puts "#{row["total_contact"].ljust(10)}   | #{lead_month.ljust(15)}  |  #{year.to_s.ljust(10)} "
        end
    end

    task :two, [:db_name] => :environment do |task, args|
        curr_year = nil
        quote_tally = 0
        # The number of unique requests (QuoteId) grouped by Month (Creation Date)
        puts "Query 2: Number of unique requests grouped by Month (2019-2022)"
        
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")
        
        puts "-------------+------------------+------------"
        puts "#{"Total Quote".ljust(10)}  | #{"Month".ljust(15)}  | #{"Year".ljust(10)}   "
        puts "-------------+------------------+------------"

        conn.exec("SELECT COUNT(id) as total_quote, date_trunc('month', created_at) as month FROM quote_fact GROUP BY date_trunc('month', created_at) ORDER BY date_trunc('month', created_at)").to_a.each do |row|
            year = Date.parse(row["month"]).year
            lead_month = month[Date.parse(row["month"]).mon - 1]
            puts "#{row["total_quote"].ljust(10)}   | #{lead_month.ljust(15)}  |  #{year.to_s.ljust(10)} "
        end
    end

    task :three, [:db_name] => :environment do |task, args|
        # The number of elevators (ElevatorId) contained in the buildings belonging to each customer
        puts "Query 3: Total number of elevators contained belonging to each customer (2019-2022)"
       
        #conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
        conn = PG::Connection.open(:host => host_name, :user => user_name, :password => pwd, :dbname => "#{args[:db_name]}")

        puts "-------------+-----------------------------+-------------"
        puts "#{"Nb. Elev".ljust(10)}   | #{"Customer Name".ljust(25)}   | #{"Cust ID".ljust(10)} "
        puts "-------------+-----------------------------+-------------"
        conn.exec("SELECT num_elev, id, contact_full_name FROM dim_customer").to_a.each do |row|
            puts "#{row["num_elev"].ljust(10)}   | #{row["contact_full_name"].ljust(25)}   | #{row["id"].ljust(10)} "
        end
    end

end

# NOTE: LOCAL HOST

# require 'pg'

# #databasename: foobarwarehouse
# desc "Create data warehouse for facts and dimensions."

# month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

# namespace :warehouse do

#     task :create_quoteFact, [:db_name] do |task, args|
#         puts "connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         conn.exec("CREATE TABLE IF NOT EXISTS quote_fact (
#             id SERIAL PRIMARY KEY,
#             company_name VARCHAR(50) NOT NULL,
#             email VARCHAR(255) UNIQUE NOT NULL,
#             num_elev INTEGER NOT NULL,
#             created_at TIMESTAMP NOT NULL
#         )");
#         puts "...quote_fact table created"
#     end

#     task :import_quoteFact, [:db_name] => :environment do |task, args|        
#         puts "Connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         count = 0
#         Quote.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |quote|
#             quote.company_name.sub! '\'', '"'
#             conn.exec("INSERT INTO quote_fact (id, company_name, email, num_elev, created_at) VALUES ('#{quote.id}', '#{quote.company_name}', '#{quote.email}', '#{quote.num_elev}', '#{quote.created_at}')")
#             count += 1
#         end
#         puts "... a total of quote form records #{count} was saved to data warehouse at table: quote_fact."
#     end

#     ########################################################################
#     ########################################################################

#     task :create_contactFact, [:db_name] do |task, args|
#         puts "connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         conn.exec("CREATE TABLE IF NOT EXISTS contact_fact (
#             id SERIAL PRIMARY KEY,
#             company_name VARCHAR(50) NOT NULL,
#             email VARCHAR(255) UNIQUE NOT NULL,
#             project_name VARCHAR(255) NOT NULL,
#             created_at TIMESTAMP NOT NULL
#         )");
#         puts "...contact_fact table created."
#     end

#     task :import_contactFact, [:db_name] => :environment do |task, args|        
#         puts "Connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         count = 0
#         Lead.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |lead|

#             lead.company_name.sub! '\'', '"'
#             lead.project_name.sub! '\'', '"'

#             conn.exec("INSERT INTO contact_fact (id, company_name, email, project_name, created_at) VALUES ('#{lead.id}', '#{lead.company_name}', '#{lead.email}', '#{lead.project_name}', '#{lead.created_at}')")
#             count += 1
#         end  
#         puts "... a total of #{count} leads was saved to data warehouse at table: contact_fact."
#     end

#     ########################################################################
#     ########################################################################

#     task :create_elevFact, [:db_name] do |task, args|
#         puts "connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         conn.exec("CREATE TABLE IF NOT EXISTS elevator_fact (
#             id SERIAL PRIMARY KEY,
#             serial_number VARCHAR(255) NOT NULL,
#             commission_date TIMESTAMP NOT NULL,
#             building_id INTEGER NOT NULL,
#             customer_id INTEGER NOT NULL,
#             building_city VARCHAR(50) NOT NULL
#         )")
#     end

#     task :import_elevFact, [:db_name] => :environment do |task, args|        
#         puts "Connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         count = 0
#         Elevator.where(created_at: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |elevator|
            
#             # elevator_id > column_id > battery_id > building_id > customer_id 
#             building_id = Battery.find(Column.find(elevator.column_id).battery_id).building_id
#             # customer_id
#             customer_id = Building.find(building_id).customer_id
#             city = Address.find(Building.find(building_id).address_id).city

#             if city 
#                 city.sub! '\'', '"'
#             end

#             conn.exec("INSERT INTO elevator_fact (id, serial_number, commission_date, building_id, customer_id, building_city) VALUES ('#{elevator.id}', '#{elevator.serial_number}', '#{elevator.date_of_commissioning}', '#{building_id}', '#{customer_id}', '#{city}')")
#             count += 1
#         end
#         puts "... a total of #{count} elevator data was saved to warehouse at table: elevator_fact."
#     end

#     ########################################################################
#     ######################################################################## 

#     task :create_dimCustomer, [:db_name] do |task, args|
#         puts "connected to #{args[:db_name]}"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         conn.exec("CREATE TABLE IF NOT EXISTS dim_customer (
#             id SERIAL PRIMARY KEY,
#             customer_creation_date TIMESTAMP NOT NULL,
#             company_name VARCHAR(50) NOT NULL,
#             contact_full_name VARCHAR(255) NOT NULL,
#             email VARCHAR(255) UNIQUE NOT NULL,
#             num_elev INTEGER NOT NULL,
#             city VARCHAR(50) NOT NULL
#         )");
#         puts "...dim_customer table created"
#     end

#     task :import_dimCustomer, [:db_name] => :environment do |task, args|        
#         puts "Connected to #{args[:db_name]}..."
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         count = 0
#         Customer.where(customer_creation_date: Time.parse("Jan 2019")..Time.parse("Dec 2022")).each do |customer|
#             num_elev = 0
#             Elevator.all.each do |elevator|
#                 if Building.find(Battery.find(Column.find(elevator.column_id).battery_id).building_id).customer_id == customer.id
#                     num_elev += 1
#                 end
#             end
#             customer.company_name.sub! '\'', '"'
#             customer.full_name_of_the_company_contact.sub! '\'', '"'
#             conn.exec("INSERT INTO dim_customer (id, customer_creation_date, company_name, contact_full_name, email, city, num_elev) VALUES ('#{customer.id}', '#{customer.customer_creation_date}', '#{customer.company_name}', '#{customer.full_name_of_the_company_contact}', '#{customer.email_of_the_company_contact}', '#{Address.find(customer.address_id).city}', '#{num_elev}')")
#             count += 1
#         end
#         puts "... a total of #{count} customer data was saved to data warehouse at table: dim_customer."
#     end

# end

#     ########################################################################
#     ######################################################################## 

# namespace :query do 

#     task :one, [:db_name] => :environment do |task, args|
#         curr_year = nil
#         # The number of unique requests (ContactId) grouped by Month (Creation Date)
#         puts "Query 1: The number of unique requests grouped by Month (2019-2022)"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")

#         puts "-------------+------------------+------------"
#         puts "#{"Total Leads".ljust(10)}  | #{"Month".ljust(15)}  | #{"Year".ljust(10)}   "
#         puts "-------------+------------------+------------"
        
#         conn.exec("SELECT COUNT(id) as total_contact, date_trunc('month', created_at) as month FROM contact_fact GROUP BY date_trunc('month', created_at) ORDER BY date_trunc('month', created_at)").to_a.each do |row|
#             year = Date.parse(row["month"]).year
#             lead_month = month[Date.parse(row["month"]).mon - 1]
#             puts "#{row["total_contact"].ljust(10)}   | #{lead_month.ljust(15)}  |  #{year.to_s.ljust(10)} "
#         end
#     end

#     task :two, [:db_name] => :environment do |task, args|
#         curr_year = nil
#         quote_tally = 0
#         # The number of unique requests (QuoteId) grouped by Month (Creation Date)
#         puts "Query 2: Number of unique requests grouped by Month (2019-2022)"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")

#         puts "-------------+------------------+------------"
#         puts "#{"Total Quote".ljust(10)}  | #{"Month".ljust(15)}  | #{"Year".ljust(10)}   "
#         puts "-------------+------------------+------------"

#         conn.exec("SELECT COUNT(id) as total_quote, date_trunc('month', created_at) as month FROM quote_fact GROUP BY date_trunc('month', created_at) ORDER BY date_trunc('month', created_at)").to_a.each do |row|
#             year = Date.parse(row["month"]).year
#             lead_month = month[Date.parse(row["month"]).mon - 1]
#             puts "#{row["total_quote"].ljust(10)}   | #{lead_month.ljust(15)}  |  #{year.to_s.ljust(10)} "
#         end
#     end

#     task :three, [:db_name] => :environment do |task, args|
#         # The number of elevators (ElevatorId) contained in the buildings belonging to each customer
#         puts "Query 3: Total number of elevators contained belonging to each customer (2019-2022)"
#         conn = PG::Connection.open(:dbname => "#{args[:db_name]}")
#         puts "-------------+-----------------------------+-------------"
#         puts "#{"Nb. Elev".ljust(10)}   | #{"Customer Name".ljust(25)}   | #{"Cust ID".ljust(10)} "
#         puts "-------------+-----------------------------+-------------"
#         conn.exec("SELECT num_elev, id, contact_full_name FROM dim_customer").to_a.each do |row|
#             puts "#{row["num_elev"].ljust(10)}   | #{row["contact_full_name"].ljust(25)}   | #{row["id"].ljust(10)} "
#         end
#     end

# end