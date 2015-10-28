# ZenDesk Daily Time Logged Report Script
`generateZenDeskTimeReport.rb` leverages the ZenDesk v2 API and generates a report of all time logged for each agent since the report start time.  Time is recorded and saved using the ZenDesk App: [`zendesk/timetracking_app`](https://github.com/zendesk/timetracking_app).  

# Setup / Usage

## Download the script / clone the repo

    git clone https://github.com/bryankaraffa/rs-zendesk_timeloggedReport.git

## Install ZenDesk API Client [Ruby gem]
The [Zendesk Ruby API client](https://github.com/zendesk/zendesk_api_client_rb) can be installed using Rubygems:

    gem install zendesk_api

## Configure Inputs
### Required:
#### $zendesk_url
The API URL for your ZenDesk deployment
#### $zendesk_email
The ZenDesk user to use to access the ZenDesk API [must have `admin` privileges]
#### $zendesk_token
The API token for the ZenDesk user to authenticate with.  API tokens are managed in the Zendesk Admin interface at **Admin > Channels > API**.
#### $zendesk_reportLength [optional]
Report length [in seconds].  Default is `86400` [24 hours] if not specified.  Cannot be used in conjunction with `$zendesk_reportStartTime`
#### $zendesk_reportStartTime [optional]

_NOTE:  If $zendesk_reportStartTime is set, then $zendesk_reportLength is **ignored**_

## Run Script

     export zendesk_url="https://mycompany.zendesk.com/api/v2"
     export zendesk_email="myuser@mycompany.com"
     export zendesk_token="ABC__super-secret-token__XYZ"
     export zendesk_reportLength=43200
     
     ruby generateZenDeskTimeReport.rb
     
# Sample Output
All times are reported in seconds.
```
Report Length:      24:00:00 [hh:mm:ss]
Report Start Time:  2015-10-27 19:04:59 UTC
Report End Time:    2015-10-28 19:04:59 UTC  [current time in UTC]
 
--Results--
bob.plummer@mycompany.com: 03:56:00 [hh:mm:ss]
jane.doe@mycompany.com: 04:28:00 [hh:mm:ss]
bryan.karaffa@mycompany.com: 07:45:00 [hh:mm:ss]
--Debugging--
{
  "1160496237": {
    "email": "bob.plummer@mycompany.com",
    "totalTime": 14160,
    "tickets": {
      "96292": 6240,
      "97515": 7920
    }
  },
  "1166315698": {
    "email": "jane.doe@mycompany.com",
    "totalTime": 16080,
    "tickets": {
      "97468": 4140,
      "97612": 8940,
      "97695": 3000
    }
  },
  "1160491037": {
    "email": "bryan.karaffa@rightscale.com",
    "totalTime": 27900,
    "tickets": {
      "97375": 1500,
      "41316": 900,
      "97489": 300,
      "96924": 300,
      "97618": 3600,
      "97621": 1200,
      "97397": 5400,
      "95379": 600,
      "97296": 600,
      "97698": 3000,
      "97619": 10500
    }
  }
}
```