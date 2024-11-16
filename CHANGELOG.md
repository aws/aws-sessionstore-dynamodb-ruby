3.0.1 (2024-11-16)
------------------

* Issue - `Configuration` now takes environment variables with precedence over YAML configuration.

* Issue - Use ENV variables that are prefixed by `AWS_`.

3.0.0 (2024-10-29)
------------------

* Feature - Uses `rack ~> 3` as the minimum.

* Feature - Drop support for Ruby 2.5 and 2.6.

* Feature - Support additional configuration options through ENV.

* Feature - Moves error classes into the `Errors` module.

* Issue - Set `RackMiddleware`'s `#find_session`, `#write_session`, and `#delete_session` as public.

* Issue - Validate `Configuration` has a secret key on `RackMiddleware#initialize` instead of on `#find_session`.

2.2.0 (2024-01-25)
------------------

* Feature - Drop support for Ruby 2.3 and 2.4.

* Issue - Relax `rack` dependency to allow version 3. Adds `rack-session` to the gemspec.

2.1.0 (2023-06-02)
------------------

* Feature - Improve User-Agent tracking and bump minimum DynamoDB version.

2.0.1 (2020-11-16)
------------------

* Issue - Expose `:config` in `RackMiddleware` and `:config_file` in `Configuration`.

* Issue - V2 of this release was still loading SDK V1 credential keys. This removes support for client options specified in YAML configuration (behavior change). Instead, construct `Aws::DynamoDB::Client` and use the `dynamo_db_client` option.

2.0.0 (2020-11-11)
------------------

* Remove Rails support (moved to the `aws-sdk-rails` gem).

* Use V3 of Ruby SDK

* Fix a `dynamo_db.scan()` incompatibility from the V1 -> V2 upgrade in the garbage collector.

1.0.0 (2017-08-14)
------------------

* Use V2 of Ruby SDK (no history)


0.5.1 (2015-08-26)
------------------

* Bug Fix (no history)

0.5.0 (2013-08-27)
------------------

* Initial Release (no history)
