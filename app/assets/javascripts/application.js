//= require jquery
//= require govuk_publishing_components/modules
//= require govuk_publishing_components/lib/cookie-functions
//= require govuk_publishing_components/components/button
//= require govuk_publishing_components/components/character-count
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/cookie-banner
//= require govuk_publishing_components/components/error-summary
//= require govuk_publishing_components/components/radio
//= require stripPII
//= require analytics
//= require cookies
window.CookieSettings.start()

if (window.GOVUK.analyticsInit) {
  window.GOVUK.analyticsInit()
}

$(document).ready(function () {
  window.GOVUK.modules.start()
})
