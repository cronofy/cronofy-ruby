# Cronofy

[![Join the chat at https://gitter.im/cronofy/cronofy-ruby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/cronofy/cronofy-ruby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[Cronofy](http://www.cronofy.com) - one API for all the calendars (Google, Outlook, iCloud, Exchange). This gem is an interface for easy use of [Cronofy API](http://www.cronofy.com/developers/api) with Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cronofy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cronofy

## Usage

You have to register on cronofy website and create an application there. You will get a client id and client secret which you will have to pass to initializer. You can also pass a token that you will get later, or leave it blank in case if you don't have it now:
```ruby
cronofy = Cronofy.new('CLIENT_ID', 'CLIENT_SECRET', 'TOKEN')
```

Generate a link for a user to grant access for his calendars:
```ruby
cronofy.user_auth_link('http://localhost:3000/oauth2/callback')
```

The specified url is a page on your website that will handle callback and get a code parameter out of it. On a callback you will have a param[:code] that you will need in order to get a token:
```ruby
token = cronofy.get_token_from_code(code, 'http://localhost:3000/oauth2/callback')
```
You can now save a token to pass it later to initializer.

Get a list of all the user calendars:
```ruby
cronofy.list_calendars
```

You will get a list of user's calendars in a json format. The example of such a response:
```json
{
   "calendars":[
      {
         "provider_name":"google",
         "profile_name":"YYYYYYYY@gmail.com",
         "calendar_id":"cal_YYYYYYYY-UNIQUE_CAL_ID_HERE-YYYYYYYY",
         "calendar_name":"Office Calendar",
         "calendar_readonly":false,
         "calendar_deleted":false
      },
      {
         "provider_name":"google",
         "profile_name":"XXXXXXX@gmail.com",
         "calendar_id":"cal_XXXXXXXX-UNIQUE_CAL_ID_HERE-XXXXXXXXX",
         "calendar_name":"Home Calendar",
         "calendar_readonly":false,
         "calendar_deleted":false
      }
   ]
}
```

To create/update an event in user's calendar:
```ruby
event_data = {
  event_id: 'uniq-id', # uniq id of event
  summary: 'Event summary',
  description: 'Event description',
  start: Time.now + 60 * 60 * 24, # will be converted to .utc.iso8601 internally,
  end: Time.now + 60 * 60 * 25, # the same convertion here
  location: {
    description: "Meeting room"
  }
}
cronofy.create_or_update_event(calendar_id, event_data)
```

To delete an event from user's calendar:
```ruby
cronofy.delete_event(calendar_id, event_id)
```
