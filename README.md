# Lever Postings API

A Ruby client for [Lever.co's Postings API](https://github.com/lever/postings-api). This gem is limited to the functionality of Lever.co's Postings API (which is separate from their more comprehensive Lever API) and is intended to be used for the display of, and application to, jobs on your own web site. For more information see: https://github.com/lever/postings-api

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lever_postings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lever_postings

## Usage

### Get Job Postings

Job postings for a company:
```ruby
LeverPostings.postings "<site name, ex: leverdemo>"
```

Individual job posting:
```ruby
LeverPostings.postings "<site name, ex: leverdemo>", id: "<specific job posting ID>"
```

Job postings for a company with query parameters:
```ruby
LeverPostings.postings "<site name, ex: leverdemo>", team: "engineer", location: "San Francisco"
```

| Query parameter | Description                   |
| --------------- | ----------------------------- |
| mode            | The rendering output mode. json or html. Default is json. |
| skip            | skip N from the start |
| limit           | only return at most N results |
| location        | Filter postings by location |
| commitment      | Filter postings by commitment. |
| team            | Filter postings by team. |
| level           | Filter postings by level. |
| group           | May be one of `location`, `commitment`, or `team`. Returns results grouped by category |


#### Posting Result Example

JSON results are parsed and converted into Hashie::Mash objects for property style access to data (posting.text instead of posting[:text]).

| Field       | Description                   |
| ----------- | ----------------------------- |
| id          | Unique Job ID
| text        | Posting name
| categories  | Object with location, commitment and team
| description | Job description
| lists       | Extra lists of things like requirements from the job posting. This is a list of `{text:NAME, content:"unstyled HTML of list elements"}`
| additional  | Optional closing content for the job posting. May be an empty string.
| id          | Unique Job ID
| hostedUrl   | A URL which points to lever's hosted job posting page. [Example](https://jobs.lever.co/leverdemo/5ac21346-8e0c-4494-8e7a-3eb92ff77902)
| applyUrl    | A URL which points to lever's hosted application form to apply to the job posting. [Example](https://jobs.lever.co/leverdemo/5ac21346-8e0c-4494-8e7a-3eb92ff77902/apply)

```ruby
posting = LeverPostings.postings("<site name, ex: leverdemo>")[0]
posting.id # => "5ac21346-8e0c-4494-8e7a-3eb92ff77902"
posting.text # => "Account Executive"
posting.description # => "Be a foundational member on a fast-growing sales team..."
posting.lists # => [
  # { text => "WITHIN ONE MONTH YOU WILL:"
  #   content => "<li>Thoroughly know our customers, their needs, and ..." },
  # { text => "WITHIN 3 MONTHS YOU WILL:"
  #   content => "<li>Master a consultative strategy to sell Lever’s..." },
  # { text => "WITHIN 6 MONTHS YOU WILL:"
  #   content => "<li>Shape, iterate, and scale our sales strategy..." }
  # ]
posting.lists[0].text # => "WITHIN ONE MONTH YOU WILL:"
posting.created_at # => 1380917667108
posting.hostedUrl # => "https://jobs.lever.co/leverdemo/5ac21346-8e0c-4494-8e7a-3eb92ff77902"
posting.applyUrl # => "https://jobs.lever.co/leverdemo/5ac21346-8e0c-4494-8e7a-3eb92ff77902/apply"
posting.categories # => { team => "Sales"
#     location => "Mountain View"
#     commitment => "Full-time" }
# ]
posting.categories.team # => "Sales"
```

### Apply to a job posting

This enables you to add job applicants via a custom form on your site.

The API is modeled off Lever's hosted jobs form. If in doubt about custom
fields, look at any job application form on jobs.lever.co, [for example
here](https://jobs.lever.co/leverdemo/491029da-9b63-4208-83f6-c976b6fe2ac5/apply).

To use the POST API you need an API key. For now, this must be configured by a Lever employee. Contact support and they can set you up.

```ruby
LeverPostings.apply "<site name, ex: leverdemo>", "<API key>", {
  posting_id: "<specific job posting ID>",
  name: "Spock",
  email: "spock@yourcompany.com",
  resume: File.open("/path/to/resume.ext"),
  phone: "415-555-5555",
  org: "United Federation of Planets",
  urls: {
    github: "https://github.com/spock",
    twitter: "https://twitter.com/spock" },
  comments: "LLAP",
  silent: true
}
```

When testing be aware that Lever de-duplicates candidates using their email address. You won't see duplicate testing candidates appear on hire.lever.co.

The candidate will be emailed after they apply to the job, unless the `silent` field is set to true


| Field             | Description                   |
| ----------------- | ----------------------------- |
| `name` (*required*) | Candidate's named |
| `email` (*required*)| Email address |
| `resume`            | Résumé data. Must be a file.
| `phone`             | Phone number
| `org`               | Current company / organization
| `urls`              | Hash of URLs for sites (Github, Twitter, LinkedIn, Portfolio, Other, etc): `{ github: "https://github.com/lever", twitter: "https://twitte.com/lever" }`
| `comments`          | Additional information from the candidate
| `silent`            | Disables confirmation email sent to candidates upon application

The server will respond with JSON object.

- On success, **200 OK** and a body of `{ok:true, applicationId: '...'}`
- The applicationId returned can be used to view the candidate profile in Lever at the url: `https://hire.lever.co/search/application/{applicationId}`. Note that only users logged in to Lever will be able to access that page.
- On error, Lever will send the appropriate HTTP error code and a body of `{ok:false, error:<error string>}`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/otelic/lever_postings. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
