require 'spec_helper'

RSpec.describe TNT do
  let(:conref) { 'LNT_REF' }
  let(:customerref) { 'LNT_CREF' }
  let(:address) do
    {
      companyname: 'Lunet Studio SRL',
      streetaddress1: 'Bld. Lascar Catargiu 15A, 12, Sector 1',
      city: 'Bucharest',
      postcode: '010661',
      country: 'RO',
      account: ENV['TNT_ACCOUNT_ID'],
      contactname: 'Lunet Studio SRL',
      contactdialcode: '+40',
      contacttelephone: '728547184',
      contactemail: 'hello@luneteyewear.com'
    }.transform_values(&:to_s)
  end
  let(:shipment_data) do
    {
      login: TNT::Shipment.credentials,
      consignmentbatch: {
        sender: address.dup.merge(
          collection: {
            collectionaddress: address.reject { |k_| k_.to_s == 'account' },
            shipdate: (Date.today + 1).strftime('%d/%m/%Y'),
            prefcollecttime: { from: '09:00', to: '16:00' },
            collinstructions: ''
          }
        ),
        consignment: {
          conref: conref,
          details: {
            receiver: address.reject { |k_| k_.to_s == 'account' },
            delivery: address.reject { |k_| k_.to_s == 'account' },
            customerref: customerref,
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
        create: { conref: conref },
        book: { conref: conref, '@ShowBookingRef': 'Y' },
        ship: { conref: conref }
      }
    }
  end
  let(:shipment) do
    TNT::Shipment.create(shipment_data)
  end

  let(:vcr_cassette) { 'tnt_create' }

  before { VCR.insert_cassette(vcr_cassette) }

  after { VCR.eject_cassette(vcr_cassette) }

  it do
    expect(shipment).to be_a(TNT::Shipment)
    expect(shipment.create['conref']).to eq(conref)
    expect(shipment.create['success']).to eq('Y')
    expect(shipment.create['connumber'].to_s.size).to eq(13)

    expect(shipment.book['consignment']['conref']).to eq(conref)
    expect(shipment.book['consignment']['success']).to eq('Y')

    expect(shipment.ship['consignment']['conref']).to eq(conref)
    expect(shipment.ship['consignment']['success']).to eq('Y')
  end

  context 'on error' do
    let(:address) { {} }
    let(:vcr_cassette) { 'tnt_error' }

    it do
      expect { shipment }.to raise_error(
        HTTP::RestClient::ResponseError,
        /Invalid content was found starting with element 'COLLECTION'/
      )
    end
  end
end
