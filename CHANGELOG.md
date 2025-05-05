# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.2.0] - 2025-05-05
### Changed
- do not limit dependency versions
## [3.1.0] - 2024-02-13
### Removed
- support of ruby2.x
### Changed
- update dependencies && ruby 3.3 support

## [3.0.0] - 2022-02-21
### Changed
- ruby 3.0 support
- fix oauth2 no method error by upgrade to latest
- rails 6+ support
### Fixed
- token expire exception if refresh_token is expired or invalid
### Removed
- rails4 support (migrations, rspec ...)

## [2.6.1] - 2021-10-21
### Added
- methods ip_address and ip_details into Mautic::Submissions::Form

## [2.6.0] - 2021-02-08
### Added
- \#23 Stage
  - add / remove directly on contact
  - Stage model
## [2.5.0] - 2020-12-26
### Removed
- unnecessary assets (`mautic_manifest.js`)
### Added
- Form#submission - to get submission
- Form#submissions - list of all form submissions
- fields contact/company
- option `data_name` in proxy for change source json root name
## [2.4.0] - 2020-11-26
### Added
- Campaigns
  - add contact to campaign
  - remove contact from campaign
  - list contacts campaigns from Contact model
### Changed
- .rubocop (normal indentation)
## [2.3.11] - 2020-09-30
### Added
- permit `referer` in submission
## [2.3.10] - 2020-09-02
### Fixed
- work with tags on contact
### Added
- Tag::Collection for add / remove tag

## [2.3.9] - 2020-07-07
### Security
- Control access to Mautic::ConnectionsController
## [2.3.8] - 2020-06-24
### Fixed
- contacts tags should be array of their names
### Removed
- update contact tags in mautic
## [2.3.7] - 2020-06-10
### Fixed
- Model attributes should be Symbols
## [2.3.6] - 2020-06-10
### Added
- Contact Owner usage / able to change
## [2.3.5] - 2020-02-12
### Added
- Do Not Contact implementation
## [2.3.4] - 2020-02-10
### Changed
- Mautic 500 error response contains mixed HTML and json (https://github.com/mautic/mautic/issues/8406)
## [2.3.3] - 2019-11-07
### Added
- enable travis
### Changed
- improve readme.md for more detail setup instruction (#9)
### Fixed
- mautic multiple field format
## [2.3.2] - 2019-03-31
### Added
- this file
### Changed
- codestyle based rubocop
