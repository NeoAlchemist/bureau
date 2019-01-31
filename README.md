#Bureau: Elixir Jobs example

This is just an example of phoenix umbrella project. 
The contex of this project is just build simple web site for posting Elixir jobs, nothing to complicate.
I didn't spend to much time on css and design, I used [siimple](https://docs.siimple.xyz) css framework.

See other examples:

[Elixir_jobs](https://github.com/odarriba/elixir_jobs)
[Elixir_career](https://github.com/manusajith/elixirjobs)

#What it has

* Admin Dashboard 
* Users and Job Offers Managment
* Authentication and Authorization for different type of users
* Email (Confirmation | Password Reset | Templates )

## Technologies used

1. Erlang  21
2. Elixir  1.8
3. Phoenix 1.4
4. PostgreSQl

#Set up project

```
$ cd bureau_umbrella
$ cp -vr apps/bureau_web/assets/admin apps/bureau_web/priv/static/
$ mix deps.get
$ cd apps/bureau
$ mix ecto.create
$ mix ecto.migrate
```

Also for Bcrypt library you will need to install `make gcc libc-dev`. You can find documentation [here](https://github.com/riverrun/bcrypt_elixir).

Once you install all dependency please create file `.env` inside main project folder (/bureau_umbrella).

Write this inside `.env` file:

```
export ADMIN_PASS='HASHED PASSWORD FOR ADMIN'
export ADMIN_NAME="ADMIN USERNAME"
export MAILGUN_KEY="PRODUCTION KEY"
export MY_EMAIL="YOUR EMAIL ADDRESS FOR DEV TEST"
export MY_PASSWORD="YOUR EMAIL PASSWORD"
```

If you don't want to use MailGun you can check [Bamboo](https://github.com/thoughtbot/bamboo) 

