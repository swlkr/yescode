# Changelog

All notable changes to this project will be documented in this file

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

# Unreleased

### Breaking Changes

- Drop dependency on Rack::Csrf and replace with YesCsrf (Change `Rack::Csrf` in `app` to `YesCsrf`)
- Delete routes class method from `App`
- `count` and `all` methods no longer exist on `YesRecord` as methods
- Combine controllers and views into `YesComponent`
- Change routing to route to components
- Change render to render components
- Components declare `get` and `post` methods
- `queries` dropped in `YesRecord`
- Query caching is also dropped
- Use `.html.erb` instead of `.emote`
- Delete every class method in `YesRoutes` except for `route`

### Features

- Static types with Ruby 3, RBS and Steep!
- Use falcon as default webserver not tipi
- Add options to `default_session_cookie`
- Add `define_queries` method to define the sql queries as singleton methods
- Make `define_queries` the default in generators
- Components combine controllers and view classes
- Erb via erubi

### Examples

A quick example of how everything fits together

```rb
# app/components/home.rb
class Home
  attr_accessor :message

  def get
    @message = "Hello world"
  end
end

class Routes < YesRoutes
  route "/", Home
end
```

in `./app/components/home.html.erb`:

```erb
<h1>
  <%= message %>
</h1>
```

# [22.05.24]

Switched to calendar versioning, the new format is YY.MM.DD

### Fixes

No fixes :tada:

### Features

- Add a json response helper
- Add render method to controller which can disable layout at runtime
- Add action routing
- Add actions routing
- Add resources routing

The new `action` method:

```rb
class Routes < YesRoutes
  action "/signup", :Signups
end

# elsewhere in the signups controller
class Signups < YesController
  # GET /signup
  def new
  end

  # POST /signup
  def create
  end
end
```

`actions` is very similar to `action`

```rb
class Routes < YesRoutes
  actions "/profile", :Profile
end

# elsewhere in the signups controller
class Profile < YesController
  # GET /profile
  def show
  end

  # GET /profile/new
  def new
  end

  # POST /profile/new
  def create
  end

  # GET /profile/edit
  def edit
  end

  # POST /profile/edit
  def update
  end

  # POST /profile/delete
  def delete
  end
end
```

Finally, resources is a more flexible version of `resource`

```rb
class Routes < YesRoutes
  resources "/todos/:todo_id", :Todos
end

# elsewhere

class Todos < YesController
  # GET /todos
  def index
  end

  # GET /todos/:todo_id
  def show
  end

  # GET /todos/new
  def new
  end

  # POST /todos/new
  def create
  end

  # GET /todos/:todo_id/edit
  def edit
  end

  # POST /todos/:todo_id/edit
  def update
  end

  # POST /todos/:todo_id/delete
  def delete
  end
end
```

# [1.1.1]

### Fixes

- Migrations and rollbacks from the yescode cli are now working as intended

# [1.1.0]

### Fixes

- Make resource routing actually work
- Added some tests around snake/pascal/camel case
- Fixed a few rough edges around migrations/rollbacks

### Features

- Removed refinements
- Prep for RBS type checking with steep
- Help messages in the yescode cli command

# [1.0.0]

- MVC
- Plain sql migrations
- Rack support
- Routing
- Vanilla js yes frame
- Ajax support
- Models are sql with a PORO on top
- Views are emote (a fork of mote) with a PORO on top
- Controllers are... you guessed it a PORO
- No tests yet
- Two examples showing hello world / crud
- Simple CLI generators
- No autoload, no zeitwerk
- No activesupport
- No ORM
