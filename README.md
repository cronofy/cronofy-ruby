# Cronofy

[![Build Status](https://travis-ci.org/cronofy/cronofy-ruby.svg?branch=master)](https://travis-ci.org/cronofy/cronofy-ruby)
[![Gem Version](https://badge.fury.io/rb/cronofy.svg)](http://badge.fury.io/rb/cronofy)
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

You have to register on the Cronofy website and create an application there. You will then get a client id and client secret.

You can either set them as the enviroment variables `CRONOFY_CLIENT_ID` and `CRONOFY_CLIENT_SECRET` and have them picked up automatically when creating a new `Cronofy::Client`, or you can specify them explicitly:

```ruby
# From environment variables
cronofy = Cronofy::Client.new
# Or explicitly
cronofy = Cronofy::Client.new(client_id: 'CLIENT_ID', client_secret: 'CLIENT_SECRET')
```

You can also pass an existing access token and refresh token if you already have a pair for the user:

```ruby
cronofy = Cronofy::Client.new(access_token: 'ACCESS_TOKEN', refresh_token: 'REFRESH_TOKEN')
```

Generate a link for a user to grant access for their calendars:

```ruby
cronofy.user_auth_link('http://localhost:3000/oauth2/callback')
```

The returned URL is a page on your website that will handle the OAuth 2.0 callback and receive a code parameter. You can then use that code to retrieve an OAuth token granting access to the user's Cronofy account:

```ruby
token = cronofy.get_token_from_code(code, 'http://localhost:3000/oauth2/callback')
```

You should save the `access_token` and `refresh_token` for later use.

Get a list of all the user calendars:

```ruby
cronofy.list_calendars
```

You will get a list of the user's calendars with each entry being a wrapped
version of the following JSON structure:

```json
{
   "provider_name": "google",
   "profile_name": "YYYYYYYY@gmail.com",
   "calendar_id": "cal_YYYYYYYY-UNIQUE_CAL_ID_HERE-YYYYYYYY",
   "calendar_name": "Office Calendar",
   "calendar_readonly": false,
   "calendar_deleted": false
}
```

The properties can be accessed like so:

```ruby
calendar = cronofy.list_calendars.first
calendar.calendar_id
# => "cal_YYYYYYYY-UNIQUE_CAL_ID_HERE-YYYYYYYY"
```

To create/update an event in user's calendar:

```ruby
event_data = {
  event_id: 'uniq-id',
  summary: 'Event summary',
  description: 'Event description',
  start: Time.now + 60 * 60 * 24,
  end: Time.now + 60 * 60 * 25,
  location: {
    description: "Meeting room"
  }
}

cronofy.upsert(calendar_id, event_data)
```

To delete an event from user's calendar:

```ruby
cronofy.delete_event(calendar_id, 'uniq-id')
```

## Links

 * [API Docs](http://www.cronofy.com/developers/api)
 * [API mailing list](https://groups.google.com/d/forum/cronofy-api)

