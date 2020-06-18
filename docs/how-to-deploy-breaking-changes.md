# How to deploy breaking changes

When we deploy changes to the form it's easy to break things for users who are currently filling in the form.

For example,

- Re-arranging questions: Users might miss a question or get asked a question twice.
- Removing or renaming routes: Could make users request a page that now 404s

We need to deploy the form is such way that provides the least disruption to the user, and doesn't prevent them from submitting the form.

## Multi-stage feature development

Also known in some circles as A-AB-B deployment.

This describes a process where changes are deployed in stages.

### Changing a question

If new questions are being added, i.e. new data is being stored in FormResponse, or questions are being removed, then the first changed deployed should make these values optional:

- So in the case of a new question, these new values will be added to normal list of properties in the JSON schema.
- In the case of removed questions, these values should be removed from the "required" list in the JSON schema.
- If the options for a question is changing, the new values should be added to the enumeration.

This means that after the work to validate FormResponse against the JSON schema is added, users won't be stopped from submitting their responses that may contain data from any "old" questions they've already completed because the schema changed midway through their journey.

Once the first change has been deployed, a second PR should be created to either:

- Make the field required
- Disallow the field
- Remove extraneous options from the field in the JSON schema.

The second PR should ideally be deployed at least 4 hours after the first one as this is the maximum amount of time a user's session can live for.

#### Notify other teams

If new questions have been added, or the options for a question have changed, the downstream data team also need to be notified about the changes before they're deployed.

This is because changes to the fields won't get pulled through automatically and delivered to their consumers (for example Local Authorities or wholesalers), so they need to know to update their scripts.
