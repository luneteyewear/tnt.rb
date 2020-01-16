# TNT (Express Web Services) 🅣🅝🅣

Ruby SDK for working with
[TNT](https://express.tnt.com/expresswebservices-website/app/landing.html)
Express Web Services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tnt.rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tnt.rb

Note, consider using the `gyoku` unreleased version directly from:
https://github.com/savonrb/gyoku

## Usage

A subset of the TNT resources are provided with this SDK:

 * `TNT::Shipment`
 * `TNT::Label`
 * `TNT::Manifest`

These resources have implemented the following methods to allow API operations:
 * `find`
 * `create`

Here's an example on how to create a transaction, capture it, and refund it:
```ruby
require 'tnt'

address = {
  companyname: 'Lunet Studio SRL',
  streetaddress1: 'Bld. Lascar Catargiu 15A, 12, Sector 1',
  city: 'Bucharest',
  postcode: '010661',
  country: 'RO',
  account: ENV['TNT_ACCOUNT_ID'],
  contactname: 'Lunet Studio SRL',
  contactdialcode: '+40',
  contacttelephone: '728547184',
  contactemail: 'hello@luneteyewear.com',
}.transform_values(&:to_s)

shipment = TNT::Shipment.create(
  login: TNT::Shipment.credentials,
  consignmentbatch: {
    sender: address.dup.merge(
      collection: {
        collectionaddress: address.dup.except(:account),
        shipdate: DateTime.tomorrow.strftime('%d/%m/%Y'),
        prefcollecttime: { from: '09:00', to: '16:00' },
        collinstructions: ''
      }
    ),
    consignment: {
      conref: 'LNT_TNT',
      details: {
        receiver: address.dup,
        delivery: address.dup,
        customerref: 'LNT_ORDER_ID',
        contype: 'N',
        paymentind: 'S',
        items: 1,
        totalweight: 0.3,
        totalvolume: 0.0025,
        service: '15N',
        option: '',
        description: '',
        deliveryinst: '',
        package: [
          {
            items: 1,
            description: 'GLASSES',
            length: 0.25,
            height: 0.05,
            width: 0.20,
            weight: 0.4
          }
        ]
      }
    }
  },
  activity: {
    create: { conref: 'LNT_TNT' },
    book: { conref: 'LNT_TNT', '@ShowBookingRef': 'Y' },
    ship: { conref: 'LNT_TNT' }
  }
)
```

### Configuration

The API keys will be loaded from your environment variables:

 * `TNT_USERNAME`
 * `TNT_PASSWORD`

Please remember, TNT will provide you separately with an **account ID**
based on your location and the type of services you opted for.

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/luneteyewear/tnt.rb. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
