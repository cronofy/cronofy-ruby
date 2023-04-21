# Cronofy

[![ruby CI](https://github.com/cronofy/cronofy-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/cronofy/cronofy-ruby/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/cronofy.svg)](http://badge.fury.io/rb/cronofy)

[Cronofy](https://www.cronofy.com) - the scheduling platform for business

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

From there you can [create an OAuth application](https://app.cronofy.com/oauth/applications/new)
to obtain an OAuth `client_id` and `client_secret` to be able to use the full API.

## Creating a client

To make calls to the Cronofy API you must create a `Cronofy::Client`. This takes
five keyword arguments, all of which are optional:

```ruby
cronofy = Cronofy::Client.new(
  client_id:     'CLIENT_ID',
  client_secret: 'CLIENT_SECRET',
  access_token:  'ACCESS_TOKEN',
  refresh_token: 'REFRESH_TOKEN',
  data_center:   :de
)
```

When using a [personal access token](https://app.cronofy.com/oauth/applications/5447ae289bd94726da00000f/tokens)
you only need to provide the `access_token` argument.

When working against your own OAuth application you will need to provide the
`client_id` and `client_secret` when [going through the authorization process](https://docs.cronofy.com/developers/api/authorization/request-authorization/)
for a user, and when [refreshing an access token](https://docs.cronofy.com/developers/api/authorization/refresh-token/).

If `client_id` and `client_secret` are not specified explicitly the values from
the environment variables `CRONOFY_CLIENT_ID` and `CRONOFY_CLIENT_SECRET` will
be used if present.

`data_center` is the two-letter designation for the data center you want to operate against - for example `:de` for Germany, or `:au` for Australia. When omitted, this defaults to the US data center.

## Authorization

[API documentation](https://docs.cronofy.com/developers/api/authorization/request-authorization/)

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

[API documentation](https://docs.cronofy.com/developers/api/calendars/list-calendars/)

Get a list of all the user's calendars:

```ruby
calendars = cronofy.list_calendars
```

## Read events

[API documentation](https://docs.cronofy.com/developers/api/events/read-events/)

Get a list of events from the user's calendars:

```ruby
events = cronofy.read_events
```

Note that the gem handles iterating through the pages on your behalf.

## Create or update events

[API documentation](https://docs.cronofy.com/developers/api/events/upsert-event/)

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

[API documentation](https://docs.cronofy.com/developers/api/events/delete-event/)

To delete an event from user's calendar:

```ruby
cronofy.delete_event(calendar_id, 'uniq-id')
```

## A feature I want is not in the SDK, how do I get it?

We add features to this SDK as they are requested, to focus on developing the Cronofy API.

If you're comfortable contributing support for an endpoint or attribute, then we love to receive pull requests!
Please create a PR mentioning the feature/API endpoint you’ve added and we’ll review it as soon as we can.

If you would like to request a feature is added by our team then please let us know by getting in touch via [support@cronofy.com](mailto:support@cronofy.com).

## Links

 * [API documentation](https://docs.cronofy.com/developers/api/)
 * [API mailing list](https://groups.google.com/d/forum/cronofy-api)

