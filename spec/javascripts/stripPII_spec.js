/* eslint-env jasmine */
/* global stripPII */

describe('stripPII', function () {
  it('returns an empty string given an empty string', function () {
    expect(stripPII('')).toEqual('')
  })

  it('returns an empty string given a null', function () {
    expect(stripPII(null)).toEqual('')
  })

  it("does nothing if there's no query string", function () {
    var givenURL = new URL('http://example.com/')
    var expectedURL = 'http://example.com/'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it('redacts a single parameter', function () {
    var givenURL = new URL('http://example.com/?test=blah')
    var expectedURL = 'http://example.com/?test=<TEST>'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it('redacts all parameters', function () {
    var givenURL = new URL('http://example.com/?product_id=12345&test=blah&reference_number=12345')
    var expectedURL = 'http://example.com/?product_id=<PRODUCT_ID>&test=<TEST>&reference_number=<REFERENCE_NUMBER>'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it('redacts parameters when a page link is present', function () {
    var givenURL = new URL('http://example.com/?test=blah&product_id=12345#page_link')
    var expectedURL = 'http://example.com/?test=<TEST>&product_id=<PRODUCT_ID>#page_link'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })
})
