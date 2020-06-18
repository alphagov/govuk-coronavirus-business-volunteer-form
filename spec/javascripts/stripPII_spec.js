describe('stripPII', function () {
  it ('returns an empty string given an empty string', function () {
    expect(stripPII('')).toEqual('')
  })

  it ('returns an empty string given a null', function () {
    expect(stripPII(null)).toEqual('')
  })

  it ('replaces nothing if there is no query string', function () {
    var givenURL = new URL('http://example.com/')
    var expectedURL = 'http://example.com/'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it ('replaces nothing if there are no redactable params', function () {
    var givenURL = new URL('http://example.com/?test=blah')
    var expectedURL = 'http://example.com/?test=blah'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it ('replaces reference_number', function() {
    var givenURL = new URL('http://example.com/?test=blah&reference_number=12345')
    var expectedURL = 'http://example.com/?test=blah&reference_number=<REFERENCE_NUMBER>'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it ('replaces product_id', function() {
    var givenURL = new URL('http://example.com/?test=blah&product_id=12345')
    var expectedURL = 'http://example.com/?test=blah&product_id=<PRODUCT_ID>'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it ('replaces both reference_number and product_id', function() {
    var givenURL = new URL('http://example.com/?product_id=12345&test=blah&reference_number=12345')
    var expectedURL = 'http://example.com/?product_id=<PRODUCT_ID>&test=blah&reference_number=<REFERENCE_NUMBER>'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })

  it ('replaces product_id with a page link', function() {
    var givenURL = new URL('http://example.com/?test=blah&product_id=12345#page_link')
    var expectedURL = 'http://example.com/?test=blah&product_id=<PRODUCT_ID>#page_link'

    expect(stripPII(givenURL)).toEqual(expectedURL)
  })
})
