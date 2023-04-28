## [0.39.0]

 * Add conferencing services authorization

## [0.38.0]

 * Add state parameter to Service Account authorizations [#104]

## [0.37.7]

 * Update Gem description

## [0.37.6]

 * Adds support for disabling and fetching the status of Real-Time Scheduling links [#100]

## [0.37.5]

 * Support `query_periods` as well as the original `available_periods` for Real-Time Scheduling and Real-Time Sequencing [#99]

## [0.37.4]

 * Support client_secret only clients being able to authorize `#availability` calls. [#97]

## [0.37.3]

 * Support `hmac_valid` as well as the original `hmac_match` for Client to verify a HMAC from a push notification using the client's secret.[#95]

## [0.37.2]

 * Support `query_periods` as well as the original `available_periods` for Availability Query and Sequenced Availability [#91]

## [0.37.1]

 * Rename `data_centre` to `data_centre` (with aliases for backwards compatibility) [#90]

## [0.37.0]

 * Add `revoke_by_token` and `revoke_by_sub` to the Client [#86]

## [0.36.1]

 * Loosen the version requirement on Hashie to allow 4.X

## [0.36.0]

 * Add support for Available Periods [#81]

## [0.35.0]

 * Add specific errors for network issues [#77]

## [0.34.0]

 * Support removing a participant from a Smart Invite [#75]

## [0.33.0]

 * Support listing Availability Rules [#74]

## [0.32.0]

 * Support Availability Rules and Scheduling Conversations [#64]

## [0.31.2]

 * Support parsing new Availability response formats [#73]

## [0.31.1]

 * No Authorization header for Real-Time Scheduling and Real-Time Sequencing [#72]

## [0.31.0]

 * Added support for Element Tokens [#69]

## [0.30.0]

 * Added support for sequencing, buffers and intervals [#62]
 * Dropped support for Ruby 2.1

## [0.29.0]

 * Added types for propose new time replies [#60]

## [0.28.1]

 * Fixed double encoding issue [#59]

## [0.28.0]

 * Added support for handling subs from Token responses [#58]

## [0.27.0]

 * Added support for Application Calendars [#57]

## [0.26.1]

 * Prevent error when disable\_warnings not available [#56]

## [0.26.0]

 * Support for batch endpoint [#53]

## [0.25.1]

 * Support for Cancelling Smart Invites [#55]

## [0.25.0]

 * Support for Smart Invites [#49]
 * Fix warning in Ruby 2.4 [#50]

## [0.24.1]

 * Disable Hashie warnings [#52]

## [0.24.0]

 * Support for revoking profile authorization [#48]

## [0.23.0]

 * Support for color with calendar creation and event upsert [#46]
 * Helper to verify push notification HMACs [#45]

## [0.22.0]

 * Splitting of Add to Calendar and Real time scheduling [#44]
 * Support for explicit linking of accounts [#43]

## [0.21.0]

 * Support Add To Calendar with availability [#40]

## [0.20.0]

 * Change invalid request message to include errors [#36]
 * Pass through times as-is if already Strings [#37]
 * Support bulk delete from specific calendars [#38]

## [0.19.0]

 * Support setting event transparency [#31]
 * Support Add To Calendar [#35]

## [0.18.0]

 * Support multiple data centres [#30]

## [0.17.0]

 * Support member-specific available periods for Availability API [#27]

## [0.16.0]

 * Support Availability API [#26]

## [0.15.0]

 * Support for upcoming geo location feature [#24]

## [0.14.0]

 * Support for setting participant status [#20]

## [0.13.0]

 * Support for listing resources [#18]

## [0.12.0]

 * Support for deleting external events [#17]

## [0.11.0]

 * Support for Enterprise Connect [#13]
 * Support for elevating permissions [#16]


[0.11.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.11.0
[0.12.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.12.0
[0.13.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.13.0
[0.14.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.14.0
[0.15.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.15.0
[0.16.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.16.0
[0.17.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.17.0
[0.18.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.18.0
[0.19.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.19.0
[0.20.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.20.0
[0.21.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.21.0
[0.22.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.22.0
[0.23.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.23.0
[0.24.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.24.0
[0.24.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.24.1
[0.25.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.25.0
[0.25.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.25.1
[0.26.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.26.0
[0.26.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.26.1
[0.27.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.27.0
[0.28.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.28.0
[0.28.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.28.1
[0.29.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.29.0
[0.30.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.30.0
[0.31.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.31.0
[0.31.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.31.1
[0.31.2]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.31.2
[0.32.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.32.0
[0.33.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.33.0
[0.34.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.34.0
[0.35.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.35.0
[0.36.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.36.0
[0.36.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.36.1
[0.37.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.0
[0.37.1]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.1
[0.37.2]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.2
[0.37.3]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.3
[0.37.4]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.4
[0.37.5]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.5
[0.37.6]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.6
[0.37.7]: https://github.com/cronofy/cronofy-ruby/releases/tag/v0.37.7
[0.38.0]: https://github.com/cronofy/cronofy-ruby/releases/tag/0.38.0
[0.39.0]: 

[#13]: https://github.com/cronofy/cronofy-ruby/pull/13
[#16]: https://github.com/cronofy/cronofy-ruby/pull/16
[#17]: https://github.com/cronofy/cronofy-ruby/pull/17
[#18]: https://github.com/cronofy/cronofy-ruby/pull/18
[#20]: https://github.com/cronofy/cronofy-ruby/pull/20
[#24]: https://github.com/cronofy/cronofy-ruby/pull/24
[#26]: https://github.com/cronofy/cronofy-ruby/pull/26
[#27]: https://github.com/cronofy/cronofy-ruby/pull/27
[#30]: https://github.com/cronofy/cronofy-ruby/pull/30
[#31]: https://github.com/cronofy/cronofy-ruby/pull/31
[#35]: https://github.com/cronofy/cronofy-ruby/pull/35
[#36]: https://github.com/cronofy/cronofy-ruby/pull/36
[#37]: https://github.com/cronofy/cronofy-ruby/pull/37
[#38]: https://github.com/cronofy/cronofy-ruby/pull/38
[#40]: https://github.com/cronofy/cronofy-ruby/pull/40
[#43]: https://github.com/cronofy/cronofy-ruby/pull/43
[#44]: https://github.com/cronofy/cronofy-ruby/pull/44
[#45]: https://github.com/cronofy/cronofy-ruby/pull/45
[#46]: https://github.com/cronofy/cronofy-ruby/pull/46
[#48]: https://github.com/cronofy/cronofy-ruby/pull/48
[#49]: https://github.com/cronofy/cronofy-ruby/pull/49
[#50]: https://github.com/cronofy/cronofy-ruby/pull/50
[#52]: https://github.com/cronofy/cronofy-ruby/pull/52
[#53]: https://github.com/cronofy/cronofy-ruby/pull/53
[#55]: https://github.com/cronofy/cronofy-ruby/pull/55
[#56]: https://github.com/cronofy/cronofy-ruby/pull/56
[#57]: https://github.com/cronofy/cronofy-ruby/pull/57
[#58]: https://github.com/cronofy/cronofy-ruby/pull/58
[#59]: https://github.com/cronofy/cronofy-ruby/pull/59
[#60]: https://github.com/cronofy/cronofy-ruby/pull/60
[#62]: https://github.com/cronofy/cronofy-ruby/pull/62
[#64]: https://github.com/cronofy/cronofy-ruby/pull/64
[#69]: https://github.com/cronofy/cronofy-ruby/pull/69
[#72]: https://github.com/cronofy/cronofy-ruby/pull/72
[#73]: https://github.com/cronofy/cronofy-ruby/pull/73
[#74]: https://github.com/cronofy/cronofy-ruby/pull/74
[#75]: https://github.com/cronofy/cronofy-ruby/pull/75
[#77]: https://github.com/cronofy/cronofy-ruby/pull/77
[#81]: https://github.com/cronofy/cronofy-ruby/pull/81
[#85]: https://github.com/cronofy/cronofy-ruby/pull/85
[#86]: https://github.com/cronofy/cronofy-ruby/pull/86
[#90]: https://github.com/cronofy/cronofy-ruby/pull/90
[#91]: https://github.com/cronofy/cronofy-ruby/pull/91
[#95]: https://github.com/cronofy/cronofy-ruby/pull/95
[#97]: https://github.com/cronofy/cronofy-ruby/pull/97
[#99]: https://github.com/cronofy/cronofy-ruby/pull/99
[#100]: https://github.com/cronofy/cronofy-ruby/pull/100
[#104]: https://github.com/cronofy/cronofy-ruby/pull/104
[#108]: https://github.com/cronofy/cronofy-ruby/pull/108
