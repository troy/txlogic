# Transmit Logic

Always reach a human. Nagging as a service.

Jump to [Screenshots](#screenshots), [Examples](#examples), [Status](#status), [Setup](#setup), or [Support](#support).


# Screenshots

## Dashboard

<img src="https://github.com/troy/txlogic/raw/master/doc/screenshots/dashboard.jpg" height=35% width=35%>

[Larger](https://github.com/troy/txlogic/raw/master/doc/screenshots/dashboard.jpg)

## Define alert process

<img src="https://github.com/troy/txlogic/raw/master/doc/screenshots/create_process.jpg" height=35% width=35%>

[Larger](https://github.com/troy/txlogic/raw/master/doc/screenshots/create_process.jpg)


# Examples

Think of Transmit Logic as a bit like AppleScript or Automator for ops alerts. Here's the full [alert syntax].

## Basic example

Call someone, wait 5 minutes, email someone else.

```
process_definition do
  participant 'call bob', :recipient => '4155554242', :timeout => '5m'
  participant 'email Alex', :recipient => 'alex42@gmail.com'
end
```

## Advanced example

Concurrently contact Sally and Phong using self-contained alert
definitions. If neither respond, call Sally again but only at night.

```
process_definition do
  define 'notify Sally' do
    participant 'IM Sally' :recipient => 'eric@example.com', :using => 'jabber', :timeout => '2m'
    participant 'SMS Sally', :recipient => '8145557438'
  end

  define 'Gripe to Phong' do
    participant 'call phong', :recipient => '7165554288'
    participant 'sms Phong', :recipient => '7165554288'
  end

  concurrence do
    subprocess 'notify Sally'
    subprocess 'Gripe to Phong'
    participant 'Call Sally', :recipient => '2065558484', :if => '${nighttime}'
  end
end
```

Here's the full [alert syntax].


# Status

## Maturity

The app itself is stable and in production use.

It was very recently open-sourced after months of internal use. The
setup process needs work, as does the documentation of it. It probably
hard-codes configuration options which don't apply in all situations.
There's lots of room for refactoring.

## Known Problems

* Jabber IM support is incomplete. It worked at one point but the
service provider removed Jabber support and the standalone XMPP handler
isn't done.

## Functionality

Transmit Logic provides:

* a Web interface where ops staff can define who, how and when to
contact engineers. Uses an alert-specific DSL built with [ruote]. See
[Examples](#examples) or [alert syntax].
* a runtime environment for running those process definitions and
sending alerts.
* the ability to invoke alerts via HTTP POST, a third-party SMTP-to-HTTP 
gateway, or the Web interface. External monitoring services can invoke TxL 
alert processes by sending standard email alerts.
* two-way alert handling for SMS, phone calls, emails, and SIP calls (so
recipients can respond to the alert via that delivery method).
* for two-way alerts, each recipient may accept it (halting it), actively 
decline (so it continues to the next participant immediately), or halt it 
(like for a false positive).
* one-way alert delivery to many other services, like Campfire. Uses a
HTTP call to [txlogic-services] with a link back to TxL to respond.

## Dependencies

* SMTP server: outbound emails
* [Mailgun]: inbound email-to-HTTP gateway for accepting alerts via email 
(and replies to email alerts)
* [Tropo]: phone calls (to PSTN and SIP numbers), SMS
* Standalone [txlogic-services] instance (optional): other HTTP-accessible notification destinations (such as Campfire)

Adding additional providers should be relatively easy.


# Setup

Transmit Logic has 3 components. Here's how to setup:

* [Web app](#web-app). Rails app for defining, invoking, and executing alerts.
* [Alert delivery services](#alert-delivery-services), currently Tropo and Mailgun.
* [txlogic-services](#txlogic-services): Fork of [github-services] Sinatra app for sending
one-way alerts (without response choices). Optional; only needed to
use non-core notification methods.

## Web app

Clone the repo and make your modifications to it. For example, if you've just created a new git repo on a service like GitHub ([more](https://help.github.com/articles/creating-a-new-repository)) and have a `git://` URL:

```
git clone git://github.com/troy/txlogic.git
cd txlogic
git add origin git://YOUR-NEW-GIT-URL
git push
```

Follow the configuration instructions below and then deploy it. The TxL Web app can run in a standard Rails environment or on a Rails app hosting service like Heroku. To use Heroku instead, run `heroku apps:create -s cedar` and `git push` it to your new app ([more](https://devcenter.heroku.com/articles/rails3)).

### Secret token

Edit `config/initializers/secret_token.rb` to define a random token that is unique to your app.

### Database

Edit `database.yml` (or `database.yml.mysql` and rename it), then:

    bundle install
    rake db:migrate

### Settings

#### Web app email settings

Define standard Rails mailer settings in `config/application.rb` or
`config/environments/<environment>.rb`. See `config/environments/production.rb` 
for an example using `ActionMailer::Base.smtp_settings`.

The ActionMailer settings are used for emails generated by the Web app
(like new user invitations). SMTP settings for sending alerts are defined
separately below, though they may be the same.

#### Alert delivery settings

See below for step-by-step instructions to activate alert delivery services (and thereby, to obtain these settings).

Edit `config/settings.yml` and provide alert service settings. Optionally
define as environment-specific options in
`config/settings/<environment>.yml` per [rails_config].

#### Optional: Enforce SSL, hostname

For production environments with SSL and a single hostname, change 
`default_url_options` in `config/settings/production.rb`.
`application_controller.rb` will also let you enforce access on only
that hostname and/or only via SSL.


## Alert delivery services

### Tropo

Sign up for Tropo ([free](https://www.tropo.com/account/register.jsp)), then:

1. Choose `Create New Application`. Choose `Tropo Scripting`.
2. Give it a name, then click `Hosted file` and `Create a new hosted file for this application`
3. Name it txlogic.rb and paste the contents of [doc/tropo.rb] into the form.
4. Click `Save`. The application will be saved and assigned a phone number (shown on Tropo's `Applications` tab, under `Show Settings`). Copy it.
5. Go to `Your Hosted Files` in Tropo and edit the script you just created. Replace all instances of `2065551111` and `YOUR-TXLOGIC-URL.COM` with that Tropo number and the URL to your TxL Web app.
6. In your core TxL Web app installation, edit `config/settings.yml` (or an environment-specific settings file in `config/settings/`). Define your Tropo outbound voice token (shown on Tropo's `Applications` tab, under `Show Settings`).

### Mailgun

Sign up for Mailgun ([free](https://mailgun.net/signup?plan=free) or [pricing](http://www.mailgun.com/pricing), then:

1. Click the `Routes` tab, then `Create Route`.
2. Define a route for responses to alerts. Define a route with these settings, replacing `YOUR-TXLOGIC-URL.COM` with the URL to your TxL Web app: priority `1`, filter `match_recipient(r"update-.*")`, action `forward(r"https://YOUR-TXLOGIC-URL.COM/replies/mailgun")`, description `Replies to alerts (used as "Reply-to")`
3. Create a second route for bounces. Click `Create Route` again and define a route with: priority `1`, filter `match_recipient(r"alert-.*")`, action `forward(r"https://YOUR-TXLOGIC-URL.COM/alerts")`, description `Bounces (used as "From")`
4. In your core TxL Web app installation, edit `config/settings.yml` (or an environment-specific settings file in `config/settings/`). Edit the `alerts.email.reply_domain` definition to be the hostname of your Mailgun account, such as `example.mailgun.org` (shown on Mailgun's `My Accounts` tab).

### [txlogic-services]

This is a [separate app] from the core TxL Web app. It can run in a standard Ruby environment or on a service like Heroku. Here is an example on Heroku. Create a new Heroku app and clone the public repo:

```
heroku apps:create -s cedar
git clone git://github.com/troy/txlogic-services.git
```

Deploy the cloned repo to your new Heroku app. Replace YOUR-NEW-APP-NAME with the app name provided by `heroku apps:create`:

```
cd txlogic-services
git remote add heroku git@heroku.com:YOUR-NEW-APP-NAME.git
git push heroku
```

Last, in your core TxL Web app installation, edit `config/settings.yml` (or an environment-specific settings file in `config/settings/`). Edit the `alerts.services.base_url` definition to be the root URL to your new app above. For example: `http://goat-cheese-42.herokuapp.com/`.


# Support

## License

[MIT]

## Patches

Send a pull request.

## Questions

Open an issue.

## Authors

* Troy Davis, <http://troy.yort.com>, [@troyd]
* Larry Marburger, [@lmarburger]


[alert syntax]: https://github.com/troy/txlogic/wiki/Alert-syntax
[txlogic-services]: https://github.com/troy/txlogic-services
[github-services]: https://github.com/github/github-services
[ruote]: http://ruote.rubyforge.org/
[rails_config]: https://github.com/railsjedi/rails_config
[Mailgun]: http://www.mailgun.com/
[Tropo]: http://tropo.com/
[doc/tropo.rb]: https://github.com/troy/txlogic/blob/master/doc/tropo.rb
[separate app]: https://github.com/troy/txlogic-services
[MIT]: http://opensource.org/licenses/MIT
[@troyd]: http://twitter.com/troyd
[@lmarburger]: http://twitter.com/lmarburger
