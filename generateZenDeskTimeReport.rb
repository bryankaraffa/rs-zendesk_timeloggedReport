
require 'zendesk_api'
require 'json'

reportLength= ENV['zendesk_reportLength'] || 86400 # 24hrs in Seconds
reportStartTime= ENV['zendesk_reportStartTime'] || "#{Time.now.utc.to_i - reportLength}" # Optionally can specify the reportStartTime precisely
fieldTimeSpentLastUpdate= ENV['zendesk_fieldTimeSpentLastUpdate'] || "27024198"


zd_api = ZendeskAPI::Client.new do |config|
  # Mandatory:

  config.url = ENV['zendesk_url'] || "https://rightscale.zendesk.com/api/v2" # e.g. https://mydesk.zendesk.com/api/v2

  # Basic / Token Authentication
  config.username = ENV['zendesk_email'] || 'your@email.com'

  # Choose one of the following depending on your authentication choice
  config.token = ENV['zendesk_token'] || "your zendesk token"
  
  # Optional:

  # Retry uses middleware to notify the user
  # when hitting the rate limit, sleep automatically,
  # then retry the request.
  config.retry = true
end


seconds = reportLength % 60
minutes = (reportLength / 60) % 60
hours = reportLength / (60 * 60)
#puts "Config Details:"
#puts "API URL:  #{zd_api.config.url}"
#puts "API Username:  #{zd_api.config.username}"
#puts "Time Spent (Last Update) Field ID: #{fieldTimeSpentLastUpdate}"
puts "Report Length:      #{format("%02d:%02d:%02d", hours, minutes, seconds)} [hh:mm:ss]"
puts "Report Start Time:  #{Time.at(reportStartTime.to_i).utc}"
puts "Report End Time:    #{Time.now.utc}  [current time in UTC]"
puts " "

ticketTimeTotal = Hash.new

# Begin looping through tickets modified/created since `reportStartTime`
zd_api.ticket.incremental_export(reportStartTime).each do |ticket|

## Start-Non-Working-Method
## This will not work because the incremental_export does not return the `author_id`.
## Only the `assignee` and `submitter`/requestor are exposed so if an agent works on a ticket and is not the
## assignee or requestor, they will not get time added to their clock if this method is used.
## Solution:  Request ZenDesk to add `author_id` to the response from `incremental_exports`
##
#  if (ticket["field_#{fieldTimeSpentLastUpdate}"] != nil) && ((ticket["field_#{fieldTimeSpentLastUpdate}"]).to_i > 0)
#
#    # Create the hash if it doesn't already exist
#    if ticketTimeTotal[ticket.submitter_name] === nil
#      ticketTimeTotal[ticket.submitter_name] = Hash.new
#    end
#    if ticketTimeTotal[ticket.submitter_name][ticket.id] === nil
#      ticketTimeTotal[ticket.submitter_name][ticket.id] = 0
#    end
#    # Add the time to the ticket hash
#    ticketTimeTotal[ticket.submitter_name][ticket.id] += (ticket["field_#{fieldTimeSpentLastUpdate}"]).to_i
#    
#  end
##
## End-Non-Working-Method

## Because of said limitation with incremental_export response, we need to fetch the audit entries and manually add up the time when the event's `created_at` >= `reportStartTime`
	
	# Begin looping through audit entries in ticket
	ticket.audits.fetch.each do |audit|
    
    # Verify the Audit is == or later than the report time.
    if Time.at(audit.created_at).to_i >= reportStartTime.to_i
		  # Begin Looping through events in audit entry
      audit.events.each do |event|

        if (event.field_name == fieldTimeSpentLastUpdate) && (event.value.to_i > 0)
          # Create the Hash objects if they don't already exist
          if ticketTimeTotal[audit.author_id] === nil
            ticketTimeTotal[audit.author_id] = Hash.new
            ticketTimeTotal[audit.author_id]['email'] = zd_api.users.find(:id => audit.author_id).email
            ticketTimeTotal[audit.author_id]['totalTime']=0
            ticketTimeTotal[audit.author_id]['tickets'] = Hash.new
          end
          if ticketTimeTotal[audit.author_id]['tickets'][ticket.id] === nil
            ticketTimeTotal[audit.author_id]['tickets'][ticket.id]=0
          end
          
          # Add the time to the ticket hash
          ticketTimeTotal[audit.author_id]['tickets'][ticket.id] += event.value.to_i
          ticketTimeTotal[audit.author_id]['totalTime'] += event.value.to_i
    
        end # End Event.Field_Name If-Statement
        
      end # End Events Loop
    end #End Time.at If-Statement
	
	end # End Audits Loop	
	
end # End Tickets Loop
puts '--Results--'
ticketTimeTotal.each do |agent, values|
  total_seconds = values['totalTime']
  seconds = total_seconds % 60
  minutes = (total_seconds / 60) % 60
  hours = total_seconds / (60 * 60)
  puts "#{values['email']}: #{format("%02d:%02d:%02d", hours, minutes, seconds)} [hh:mm:ss]"
end
#puts '--Debugging--'
#puts JSON.pretty_generate(ticketTimeTotal)