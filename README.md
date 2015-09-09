# Cronofy

[![Build Status](https://travis-ci.org/cronofy/cronofy-ruby.svg?branch=master)](https://travis-ci.org/cronofy/cronofy-ruby)
[![Gem Version](https://badge.fury.io/rb/cronofy.svg)](http://badge.fury.io/rb/cronofy)

[Cronofy](https://www.cronofy.com) - one API for all the calendars (Google, iCloud, Exchange, Office 365, Outlook.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cronofy'
```

And then at your command prompt run:

```
bundle install
```

## Usage

In order to use the Cronofy API you will need to [create a developer account](https://app.cronofy.com/sign_up/new).

From there you can [create personal access tokens](https://app.cronofy.com/oauth/applications/5447ae289bd94726da00000f/tokens)
to access your own calendars, or you can [create an OAuth application](https://app.cronofy.com/oauth/applications/new)
to obtain an OAuth `client_id` and `client_secret` to be able to use the full
API.

## Creating a client

To make calls to the Cronofy API you must create a `Cronofy::Client`. This takes
four keyword arguments, all of which are optional:

```ruby
cronofy = Cronofy::Client.new(
  client_id:     'CLIENT_ID',
  client_secret: 'CLIENT_SECRET',
  access_token:  'ACCESS_TOKEN',
  refresh_token: 'REFRESH_TOKEN'
)
```

When using a [personal access token](https://app.cronofy.com/oauth/applications/5447ae289bd94726da00000f/tokens)
you only need to provide the `access_token` argument.

When working against your own OAuth application you will need to provide the
`client_id` and `client_secret` when [going through the authorization process](https://www.cronofy.com/developers/api/#authorization)
for a user, and when [refreshing an access token](https://www.cronofy.com/developers/api/#token-refresh).

If `client_id` and `client_secret` are not specified explicitly the values from
the environment variables `CRONOFY_CLIENT_ID` and `CRONOFY_CLIENT_SECRET` will
be used if present.

## Authorization

[API documentation](https://www.cronofy.com/developers/api/#authorization)

Generate a link for a user to grant access to their calendars:

```ruby
authorization_url = cronofy.user_auth_link('http://yoursite.dev/oauth2/callback')
```

The callback URL is a page on your website that will handle the OAuth 2.0
callback and receive a `code` parameter. You can then use that code to retrieve
an OAuth token granting access to the user's Cronofy account:

```ruby
response = cronofy.get_token_from_code(code, 'http://yoursite.dev/oauth2/callback')
```

You should save the response's `access_token` and `refresh_token` for later use.

Note that the **exact same** callback URL must be passed to both methods for
access to be granted.

If you use the [omniauth gem](https://rubygems.org/gems/omniauth), you can use
our [omniauth-cronofy strategy gem](https://rubygems.org/gems/omniauth-cronofy)
to perform this process.

## List calendars

[API documentation](https://www.cronofy.com/developers/api/#calendars)

Get a list of all the user's calendars:

```ruby
calendars = cronofy.list_calendars
```

## Read events

[API documentation](https://www.cronofy.com/developers/api/#read-events)

Get a list of events from the user's calendars:

```ruby
events = cronofy.read_events
```

Note that the gem handles iterating through the pages on your behalf.

## Create or update events

[API documentation](https://www.cronofy.com/developers/api/#upsert-event)

To create/update an event in the user's calendar:

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

cronofy.upsert_event(calendar_id, event_data)
```

## Delete events

[API documentation](https://www.cronofy.com/developers/api/#delete-event)

To delete an event from user's calendar:

```ruby
cronofy.delete_event(calendar_id, 'uniq-id')
```

## Links

 * [API documentation](https://www.cronofy.com/developers/api)
 * [API mailing list](https://groups.google.com/d/forum/cronofy-api)

