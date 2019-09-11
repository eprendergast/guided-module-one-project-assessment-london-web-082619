$prompt = TTY::Prompt.new 

def signin_method  #works
   user_input = $prompt.select("\nWelcome to EventBkr. Please enter your details to proceed with your booking", ["Log in", "Register"])
   if user_input == "Log in"
   log_in
else 
   register 
   selection = main_menu 
end 

end 

def register 
   first_name = $prompt.ask("First Name:", required: true)
   last_name = $prompt.ask("Last Name:", required: true)
   email = $prompt.ask("Email:", required: true) {|q|
        q.validate(/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/, 'Invalid email address')}
   password = $prompt.mask("Password:", required: true) {|q|
        q.validate(/^\S{8,}$/, "Password must include at least 8 characters")}
   user1 = User.create(first_name: first_name, last_name: last_name, email: email, password: password)
   $current_user = user1
end 

def log_in_prompt #works
   email = $prompt.ask("Email:", required: true) {|q|
        q.validate(/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/, 'Invalid email address')}
   password = $prompt.mask("Password:", required: true) 
   array = [email, password]
end 

def log_in #works
  array = log_in_prompt
  user1 = User.find_by(email: array[0])
  if user1.email == array[0] && user1.password == array[1]
      $current_user = user1

      puts "\nHere we go!\n"

      selection = main_menu 
   else #works
       i= 0
      until i == 3  
         puts "Invalid email and password. Please try again."
         array = log_in_prompt
         if user1.email == array[0] && user1.password == array[1]

             puts "\nHere we go!\n"

             selection = main_menu
         end
         i += 1
      end
   end
end 

def search
   searchmenu = $prompt.select("How would you like to refine your search?", ["Location", "Category"])
   case searchmenu 
   when "Location"
    cities = ["London", "Manchester", "Liverpool", "Edinburgh", "Oxford", "Brighton", "Birmingham", "Glasgow", "Cambridge", "Belfast", "Dublin", "Leeds", "Bath"].sort
    #requests user to select a city  
    location_input = $prompt.select("Select Location(s)", cities, filter: true)
    #given selection, returns event data for that city

    #displays random 20 events for that city as a menu
    choice = $prompt.select("Event(s) at this location", display_search_results(find_events_by_city(location_input)), filter: true)
    #displays more details about the selected event
    event_data = event_summary(choice) 
    input = $prompt.select("Options", ["Make Booking", "Main Menu"])
    if input == "Make Booking"
        num = $prompt.ask("Quantity:", required: true) #NEED TO ADD VALIDATION
        #find the event data from the API
        #create an Event Object using the data from the API
        new_event = create_event_object(event_data)
        #create a booking using the newly created event object and num of tickets input
        new_ticket = Booking.create(user_id: $current_user.id, event_id: new_event.id, number: num.to_i) 
        puts "\nCongratulations! You have secured a booking of #{num} tickets!\n"
        main_menu
    else  
        main_menu 
    end 

    when "Category"
        category_selection = $prompt.select("Select Categories", get_categories, filter: true)
        choice = $prompt.select("Event(s) with this category", display_search_results(find_events_by_category(category_selection)), filter: true)
        
        event_data = event_summary(choice) #Broken - still needs fixing
        input = $prompt.select("Options", ["Make Booking", "Main Menu"])
    if input == "Make Booking"
        num = $prompt.ask("Quantity:", required: true) #NEED TO ADD VALIDATION
        #find the event data from the API
        #create an Event Object using the data from the API
        new_event = create_event_object(event_data)
        #create a booking using the newly created event object and num of tickets input
        new_ticket = Booking.create(user_id: $current_user.id, event_id: new_event.id, number: num.to_i) 

        puts "\nCongratulations! You have secured a booking of #{new_ticket.number} tickets!\n"
        main_menu
    else  
        main_menu 
    end 
   end
end

def no_bookings 
    puts "\nYou have no bookings\n\n"
    selection = $prompt.select("What would you like to next?", ["Search For More Events", "Log Out", "End Session"])
    case selection 
    when "Search For More Events"
        search 
    when "Log Out" 
        signin_method 
    when "End Session"
        exit 
    end
end 

def main_menu
    selection = $prompt.select("Please select an option from the menu below", ["Search Events", "View My Bookings", "Log Out", "End Session"])
    case selection 
    when "Search Events" #works
        search
    when "View My Bookings" #work
        if $current_user.bookings.length == 0
            no_bookings
        else 
            my_bookings_navigation
        end 
    when "Log Out" #works
        signin_method
    when "End Session"
        exit
    end
end


def my_bookings_navigation #works
    selection = $prompt.select("You currently have #{$current_user.bookings.length} event booking(s). Please click on a ticket to see more about that event.", $current_user.booking_summary)
    # Given a selection from my_tickets_menu, return a summary of that event
    #Example selection (string): Opening Party - London
    booking_id = selection.split(" - ")[0].to_i
    booking = $current_user.bookings.find{ |booking| booking.id == booking_id }
    booking.event.event_summary
    event_summary_navigation
end

def event_summary_menu #works
    $prompt.select("Actions:", ["Modify My Bookings", "Main Menu"])
end

def event_summary_navigation

    selection1 = event_summary_menu

   if selection1 == "Modify My Bookings"
        selection2 = $prompt.select("Which booking would you like to change?", $current_user.booking_summary) #works
        
        action = $prompt.select("Actions: ", ["Change Quantity", "Refund Booking"]) #works

        case action 

        when "Change Quantity"
            booking_id = selection2.split(" - ")[0].to_i
            new_num = $prompt.ask("Updated Total Number of Tickets You Wish to Book for This Event: ") #works
            booking = $current_user.bookings.find{ |booking| booking.id == booking_id }
            booking.update(number: new_num.to_i)

            puts "\nUpdated!\n"

            main_menu

        when "Refund Booking"
            binding.pry
            booking_id = selection2.split(" - ")[0].to_i
            Booking.find_by(id: booking_id).destroy

            puts "\nYou have deleted your booking.\n" #works

            main_menu
        end 

   else #selection == "Main Menu"
        main_menu
    end

end

