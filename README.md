# Ruby on Rails Tutorial sample application

This is the sample application for
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](http://www.railstutorial.org/)
by [Michael Hartl](http://www.michaelhartl.com/).

## License

All source code in the [Ruby on Rails Tutorial](http://railstutorial.org/)
is available jointly under the MIT License and the Beerware License. See
[LICENSE.md](LICENSE.md) for details.

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
```

Next, migrate and seed the database:

```
$ rails db:migrate
$ rails db:seed
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

or in the Cloud9 server:

```
$ rails server -p $PORT -b $IP
```

## Deploying heroku

Before deploying heroku, you should create heroku account, AWS account, AWS S3 bucket, AWS IAM policy, group, account for reading / writing S3.

```
$ heroku create
$ heroku rename
$ heroku addons:add sendgrid:starter
$ heroku config:set MAILER_HOST=<activation mail sender hostname>
$ heroku config:set MAIL_FROM=<activation mail sender mail address>
$ heroku config:set S3_ACCESS_KEY=<IAM access key for S3>
$ heroku config:set S3_SECRET_KEY=<IAM secret key for S3>
$ heroku config:set S3_REGION=<region>
$ heroku config:set S3_BUCKET=<S3 bucket name>
$ git push heroku master
$ heroku run rails db:migrate
$ heroku run rails db:seed
$ heroku open
```

## For more information

For more information, see the
[*Ruby on Rails Tutorial* book](http://www.railstutorial.org/book).
