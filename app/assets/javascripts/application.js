//= require jquery
// = require govuk/all.js
//= require govuk_publishing_components/components/cookie-banner
//= require govuk_publishing_components/lib/cookie-functions
//= require analytics
//= require cookies
window.CookieSettings.start()
window.GOVUKFrontend.initAll()
if (window.GOVUK.analyticsInit) {
  window.GOVUK.analyticsInit()
}
