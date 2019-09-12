class Event < ActiveRecord::Base 
    has_many :bookings
    has_many :users, through: :bookings

    # Returns a formatted string of event info for an instance of Event
    def event_summary
        puts ""
        puts "EVENT NAME: #{self.name}"
        puts "DATE: #{self.start_time}" #NEED TO FORMAT THIS
        puts "LOCATION: #{self.location}"
        puts "CATEGORY: #{self.category}"
        puts "DESCRIPTION: #{self.description}"
        puts ""
    end

    def self.names
        self.all.map{|event| event.name}
    end 
end 