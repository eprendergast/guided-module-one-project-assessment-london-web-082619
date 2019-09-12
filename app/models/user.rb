class User < ActiveRecord::Base 
    has_many :bookings
    has_many :events, through: :bookings

  def self.emails 
    self.all.map{|user| user.email}
  end 

  def self.user_passwords 
    self.all.map{|user| user.password}
  end 

  def booking_summary
    self.bookings.map{ |booking| "BOOKING ID: #{booking.id}  |  EVENT: #{booking.event.name}  |  LOCATION: #{booking.event.location}  |  NO. OF TICKETS: #{booking.number}" }
  end

end 


