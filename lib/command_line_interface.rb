require_relative "../lib/api_communicator.rb"
class System
    @@prompt = TTY::Prompt.new 

      def self.head 
        puts ""
puts "        ████████╗██╗   ██╗██╗  ██╗████████╗███╗   ███╗ █████╗ ████████╗ ██████╗██╗  ██╗".red
puts "        ╚══██╔══╝╚██╗ ██╔╝██║ ██╔╝╚══██╔══╝████╗ ████║██╔══██╗╚══██╔══╝██╔════╝██║  ██║".yellow
puts "           ██║    ╚████╔╝ █████╔╝    ██║   ██╔████╔██║███████║   ██║   ██║     ███████║".green
puts "           ██║     ╚██╔╝  ██╔═██╗    ██║   ██║╚██╔╝██║██╔══██║   ██║   ██║     ██╔══██║".blue
puts "           ██║      ██║   ██║  ██╗   ██║██╗██║ ╚═╝ ██║██║  ██║   ██║   ╚██████╗██║  ██║".cyan
puts "           ╚═╝      ╚═╝   ╚═╝  ╚═╝   ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝".white
    end 

    def self.signin_method  #works
        self.head
        user_input = @@prompt.select("\nWelcome to Tykt.match. Please enter your details to proceed with your booking", ["Log in", "Register"])
        if user_input == "Log in"
            self.log_in
        else 
            self.register 
            selection = self.main_menu 
        end
    end 

    def self.register 
    first_name = @@prompt.ask("First Name:", required: true)
    last_name = @@prompt.ask("Last Name:", required: true)
    email = @@prompt.ask("Email:", required: true) {|q|
            q.validate(/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/, 'Invalid email address')}
    password = @@prompt.mask("Password:", required: true) {|q|
            q.validate(/^\S{8,}$/, "Password must include at least 8 characters")}
    user1 = User.create(first_name: first_name, last_name: last_name, email: email, password: password)
    @@current_user = user1
    end 

    def self.log_in_prompt #works
    email = @@prompt.ask("Email:", required: true) {|q| q.validate(/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/, 'Invalid email address')}
    password = @@prompt.mask("Password:", required: true) 
    array = [email, password]
    end 

    def self.log_in #works
        i = 0
    array = log_in_prompt
    if User.find_by(email: array[0]).email == array[0] && User.find_by(email: array[0]).password == array[1]
            @@current_user = User.find_by(email: array[0])

        puts "\nHere we go!\n"

        selection = main_menu 
    else #doesnt work if wrong email and password - WHY?
        until i == 3  
            puts "\nInvalid email and password. Please try again."
            array = log_in_prompt
            if User.find_by(email: array[0]).email == array[0] && User.find_by(email: array[0]).password == array[1]
                @@current_user = User.find_by(email: array[0])
                puts "\nHere we go!\n"

                selection = main_menu
            end
            i += 1
        end
    end
    end 

    def self.make_booking(event_data)
        num = @@prompt.ask("Quantity:", required: true) #NEED TO ADD VALIDATION
        #create an Event Object using the data from the API
        new_event = EventBrite.create_event_object(event_data)
        #create a booking using the newly created event object and num of tickets input
        new_ticket = Booking.create(user_id: @@current_user.id, event_id: new_event.id, number: num.to_i) 
        #reset current user
        @@current_user = User.find_by(first_name: @@current_user.first_name, last_name: @@current_user.last_name, email: @@current_user.email, password: @@current_user.password)
        puts "\nCongratulations! You have secured a booking of #{new_ticket.number} ticket(s) for #{new_event.name} !\n".yellow
        self.main_menu
    end

    def self.search
    searchmenu = @@prompt.select("How would you like to refine your search?", ["Location", "Category"])
    case searchmenu 
        when "Location"
            cities = ["London", "Manchester", "Liverpool", "Edinburgh", "Oxford", "Brighton", "Birmingham", "Glasgow", "Cambridge", "Belfast", "Dublin", "Leeds", "Bath"].sort
            #requests user to select a city  
            location_input = @@prompt.select("Select Location(s)", cities, filter: true)
            #displays random 10 events for that city as a menu
            selection = @@prompt.select("Event(s) at this location", EventBrite.display_search_results(EventBrite.find_events_by_city(location_input)), filter: true)
            #displays more details about the selected event
            event_data = EventBrite.event_summary(selection) 
            input = @@prompt.select("Options", ["Make Booking", "Main Menu"])
            if input == "Make Booking"
                self.make_booking(event_data)
            else  
                self.main_menu 
            end 

            when "Category"
                category_selection = @@prompt.select("Select Categories", EventBrite.get_categories, filter: true)
                selection = @@prompt.select("Event(s) with this category", EventBrite.display_search_results(EventBrite.find_events_by_category(category_selection)), filter: true)
                event_data = EventBrite.event_summary(selection)
                input = @@prompt.select("Options", ["Make Booking", "Main Menu"])
            if input == "Make Booking"
                self.make_booking(event_data)
            else  
                self.main_menu 
            end 
        end
    end

    def self.no_bookings 
        puts "\nYou have no bookings\n\n"
        selection = @@prompt.select("What would you like to next?", ["Search For More Events", "Log Out", "End Session"])
        case selection 
        when "Search For More Events"
            self.search 
        when "Log Out" 
            self.signin_method 
        when "End Session"
            exit 
        end
    end 

    def self.main_menu
        selection = @@prompt.select("Please select an option from the menu below", ["Search Events", "View My Bookings",  "Log Out", "End Session"])
        case selection 
        when "Search Events" #works
            self.search
        when "View My Bookings" #work
            if $current_user.bookings.length == 0
                self.no_bookings
            else 
                self.my_bookings_navigation
            end 
        when "Log Out" #works
            self.signin_method
        when "End Session"
            exit
        end
    end

    def self.my_bookings_navigation #works
        selection = @@prompt.select("You currently have #{@@current_user.bookings.length} event booking(s). Please click on a ticket to see more about that event.", @@current_user.booking_summary)
        # Given a selection from my_tickets_menu, return a summary of that event
        #Example selection (string): ID - Opening Party - London
        booking_id = selection.split(" - ")[0].to_i
        booking = @@current_user.bookings.find{ |booking| booking.id == booking_id }
        booking.event.event_summary
        self.event_summary_navigation
    end

    def self.event_summary_menu #works
        selection = @@prompt.select("Actions:", ["Modify My Bookings", "Main Menu"])
        if selection == "Modify My Bookings"
            self.modify_bookings 
        else 
            self.main_menu 
        end 
    end

    def self.modify_bookings
        selection2 = @@prompt.select("Which booking would you like to change?", @@current_user.booking_summary) #works
        action = @@prompt.select("Actions: ", ["Change Quantity", "Refund Booking"])

            case action 
            when "Change Quantity"
                booking_id = selection2.split(" - ")[0].to_i
                new_num = @@prompt.ask("Updated Total Number of Tickets You Wish to Book for This Event: ") #works
                booking = @@current_user.bookings.find{ |booking| booking.id == booking_id }
                booking.update(number: new_num.to_i)
                @@current_user = User.find_by(first_name: @@current_user.first_name, last_name: @@current_user.last_name, email: @@current_user.email, password: @@current_user.password)
                puts "\nUpdated!\n".yellow
                self.main_menu

            when "Refund Booking"
                booking_id = selection2.split(" - ")[0].to_i
                @@current_user.bookings.find{ |booking| booking.id == booking_id }.destroy
                @@current_user = User.find_by(first_name: @@current_user.first_name, last_name: @@current_user.last_name, email: @@current_user.email, password: @@current_user.password)
                puts "\nYou have deleted your booking.\n".yellow #works
                self.main_menu
            end 
    end 

    def self.event_summary_navigation
        selection1 = self.event_summary_menu
    if selection1 == "Modify My Bookings"
            self.modify_bookings
        else 
            self.main_menu
        end
    end

end 
