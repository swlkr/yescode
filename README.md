# yescode

A full stack ruby mvc web framework

# Learning

Check out the `examples/` folder for some ideas on how to get started

# Quickstart without docker

Install the gem

```sh
gem install yescode
```

Generate a new app and get in there

```sh
yescode new todos
cd todos
```

Install the dependencies

```sh
bundle install
```

Set the environment from the .env file

```sh
export $(cat .env | xargs)
```

Start the server

```sh
bundle exec falcon serve --count 1 --bind http://localhost:9292
```

Test it out with curl or you can just visit `http://localhost:9292` in your browser

```sh
curl localhost:9292
```

# Quickstart with docker

Install the gem

```sh
gem install yescode
```

Generate a new app and get in there

```sh
yescode new todos
cd todos
```

Build a docker image. The Dockerfile installs [hivemind](https://github.com/DarthSim/hivemind) and [watchexec](https://github.com/watchexec/watchexec) and will restart the server on file changes using Procfile.dev

```sh
docker build -t todos .
```

Run the container

```sh
docker run --rm -it -v $(pwd):/home/app --env-file=.env -p 9292:9292 --name "todos" todos hivemind Procfile.dev
```
