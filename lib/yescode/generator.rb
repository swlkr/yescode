# frozen_string_literal: true

require "fileutils"
require "securerandom"

module Yescode
  class Generator
    extend Strings

    VIEW_DIR = File.join(".", "app", "views")

    APP_HELP_MESSAGE = <<~TXT
      Usage: yescode new [name]

      Create a new Yescode application

      Example:
        yescode new todos

      This will generate a new Yescode application in ./todos
    TXT

    CONTROLLER_HELP_MESSAGE = <<~TXT
      Usage: yescode generate controller [name]

      Create a new controller with all available actions

      Example:
        yescode generate controller todos

      This will generate a controller named Todos in ./app/controllers/todos.rb
    TXT

    MIGRATION_HELP_MESSAGE = <<~TXT
      Usage: yescode generate migration [name]

      Create a new migration with -- up and -- down placeholders in ./db/migrations/[timestamp]_[migration name].sql

      Example:
        yescode generate migration create_table_todo

      This will generate a common create table sql statement below -- up and a drop table below -- down


      Example:
        yescode generate migration add_created_at_to_todo

      This will generate an empty sql file with -- up and -- down placeholders
    TXT

    MODEL_HELP_MESSAGE = <<~TXT
      Usage: yescode generate model [name]

      Create a new model

      Example:
        yescode generate model todo

      This will generate a model named Todo in ./app/models/todo.rb
    TXT

    MVC_HELP_MESSAGE = <<~TXT
      Usage: yescode generate mvc [name]

      Create a new model, common views and controller all at once

      Example:
        yescode generate mvc todo

      This will generate a model, common sql queries, views and controller:

      - ./app/models/todo.rb
      - ./app/models/todo.sql
      - ./app/controllers/todos.rb
      - ./app/views/todos_edit.rb
      - ./app/views/todos_edit.emote
      - ./app/views/todos_index.rb
      - ./app/views/todos_index.emote
      - ./app/views/todos_new.rb
      - ./app/views/todos_new.emote
      - ./app/views/todos_show.rb
      - ./app/views/todos_show.emote
    TXT

    QUERIES_HELP_MESSAGE = <<~TXT
      Usage: yescode generate queries [name]

      Create common sql queries for a given table

      Example:
        yescode generate queries todo

      This will generate common sql queries in ./app/models/todo.sql
    TXT

    TEMPLATE_HELP_MESSAGE = <<~TXT
      Usage: yescode generate template [name]

      Create a template file

      Example:
        yescode generate template todos_index

      This will generate ./app/views/todos_index.emote
    TXT

    TEMPLATES_HELP_MESSAGE = <<~TXT
      Usage: yescode generate templates [name]

      Create common templates for a given controller

      Example:
        yescode generate templates todos

      This will generate the following templates
        - ./app/views/todos_edit.emote
        - ./app/views/todos_index.emote
        - ./app/views/todos_new.emote
        - ./app/views/todos_show.emote
        - ./app/views/todos_form.emote
    TXT

    VIEW_HELP_MESSAGE = <<~TXT
      Usage: yescode generate view [name]

      Create the view and template

      Example:
        yescode generate view todos_index

      This will generate the following view and template:
        - ./app/views/todos_index.rb
        - ./app/views/todos_index.emote
    TXT

    VIEWS_HELP_MESSAGE = <<~TXT
      Usage: yescode generate views [name]

      Create common views and templates for a given controller

      Example:
        yescode generate views todos

      This will generate the following views and templates
        - ./app/views/todos_edit.rb
        - ./app/views/todos_edit.emote
        - ./app/views/todos_index.rb
        - ./app/views/todos_index.emote
        - ./app/views/todos_new.rb
        - ./app/views/todos_new.emote
        - ./app/views/todos_show.rb
        - ./app/views/todos_show.emote
        - ./app/views/todos_form.rb
        - ./app/views/todos_form.emote
    TXT

    HELP_MESSAGE = <<~TXT
      Usage: yescode generate GENERATOR [options]

      Supported yescode generators:
        controller    Create a new controller with all available actions
        migration     Create a new migration
        model         Create a new model
        mvc           Create a new model, views and controller all at once
        queries       Create common sql queries for a given table
        template      Create just a template file
        templates     Create just the templates for a given controller
        view          Create the view and template
        views         Create common views and templates for a given controller
    TXT

    class << self
      def generate(*gen_args)
        type, *args = gen_args

        case type
        when "controller"
          generate_controller(*args)
        when "queries"
          generate_queries(*args)
        when "model"
          generate_model(*args)
        when "view"
          generate_view(*args)
        when "views"
          generate_views(*args)
        when "template"
          generate_template(*args)
        when "templates"
          generate_templates(*args)
        when "migration"
          generate_migration(*args)
        when "mvc"
          generate_mvc(*args)
        when "app"
          generate_app(*args)
        else
          puts HELP_MESSAGE
        end
      end

      def generate_app(dir = nil)
        if dir.nil?
          puts APP_HELP_MESSAGE
          return
        end

        FileUtils.mkdir_p(File.join(".", dir))
        {
          "public" => %w[css js],
          "db" => %w[migrations],
          "app" => %w[models views controllers emails jobs modules]
        }.each do |k, v|
          v.each do |folder|
            FileUtils.mkdir_p(File.join(".", dir, k, folder))
          end
        end
        File.write(
          File.join(dir, "Gemfile"),
          <<~RB
          source "https://rubygems.org"
          git_source(:github) { |repo| "https://github.com/\#\{repo\}.git" }

          ruby "3.1.2"

          gem "falcon", "0.39.2"
          gem "yescode", "#{VERSION}"

          group :development do
            gem "minitest", "5.15.0"
          end
          RB
        )
        File.write(
          File.join(dir, "Dockerfile"),
          <<~DOCKER
          FROM docker.io/library/ruby:slim

          RUN apt-get update -qq
          RUN apt-get install -y --no-install-recommends build-essential libjemalloc2 fonts-liberation wget gnupg2 libc6
          RUN rm -rf /var/lib/apt/lists/*

          RUN wget https://www.sqlite.org/2022/sqlite-autoconf-3380200.tar.gz && \
              tar xvfz sqlite-autoconf-3380200.tar.gz && \
              cd sqlite-autoconf-3380200 && \
              ./configure && \
              make && \
              make install && \
              rm -rf sqlite-autoconf-3380200

          RUN wget https://github.com/watchexec/watchexec/releases/download/cli-v1.18.11/watchexec-1.18.11-x86_64-unknown-linux-gnu.tar.xz && \
              tar xf watchexec-1.18.11-x86_64-unknown-linux-gnu.tar.xz && \
              mv watchexec-1.18.11-x86_64-unknown-linux-gnu/watchexec /usr/local/bin/ && \
              rm -rf watchexec-1.18.11-x86_64-unknown-linux-gnu

          RUN wget https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz && \
              gunzip hivemind-v1.1.0-linux-amd64.gz && \
              mv hivemind-v1.1.0-linux-amd64 /usr/local/bin/hivemind && \
              chmod +x /usr/local/bin/hivemind

          ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

          ARG USER=app
          ARG GROUP=app
          ARG UID=1101
          ARG GID=1101
          ARG DIR=/home/app

          RUN groupadd --gid $GID $GROUP
          RUN useradd --uid $UID --gid $GID --groups $GROUP -ms /bin/bash $USER

          RUN chown -R $USER:$GROUP $DIR

          USER $USER
          WORKDIR $DIR

          COPY --chown=$USER Gemfile Gemfile.lock $DIR

          RUN bundle install

          COPY --chown=$USER . $DIR
          DOCKER
        )
        File.write(
          File.join(dir, "Procfile"),
          "web: bundle exec falcon serve --bind http://0.0.0.0:$PORT"
        )
        File.write(
          File.join(dir, "restart-dev-server.sh"),
          "kill -HUP $(cat tmp/server.pid | xargs)"
        )
        File.write(
          File.join(dir, "Procfile.dev"),
          <<-SH
          web: bundle exec falcon serve --count 1 --bind http://localhost:$PORT
          watch: watchexec --exts emote,rb,sql --postpone ./restart-dev-server.sh
          SH
        )
        File.write(
          File.join(dir, "config.ru"),
          <<-RB
          require "fileutils"
          require "./app"

          FILENAME = "tmp/server.pid".freeze
          FileUtils.mkdir_p("tmp")
          File.write(FILENAME, Process.ppid)

          run App.freeze.app
          RB
        )
        File.write(
          File.join(dir, "public", "404.html"),
          "<h1>404</h1>"
        )
        File.write(
          File.join(dir, "public", "500.html"),
          "<h1>500</h1>"
        )
        File.write(
          File.join(dir, "app", "routes.rb"),
          <<~RB
          class Routes < YesRoutes
            get "/", :Home, :index
          end
          RB
        )
        File.write(
          File.join(dir, "app", "controllers", "home.rb"),
          <<~RB
          class Home < YesController
            def index
              HomeIndex.new
            end
          end
          RB
        )
        File.write(
          File.join(dir, "app", "views", "home_index.rb"),
          <<~RB
          class HomeIndex < Layout
          end
          RB
        )
        File.write(
          File.join(dir, "app", "views", "home_index.emote"),
          <<~RB
          <h1>Welcome to yescode!</h1>
          RB
        )
        File.write(
          File.join(dir, "app", "views", "layout.rb"),
          <<~RB
          class Layout < YesView
            def title
              "yescode"
            end

            def description
              "Yes, another ruby mvc web framework"
            end
          end
          RB
        )
        File.write(
          File.join(dir, "app", "views", "layout.emote"),
          <<~RB
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <title>{{title}}</title>
              <meta charset="utf-8" />
              <meta name="title" description="{{title}}" />
              <meta name="description" description="{{description}}" />
              % css.each do |href|
                <link href={{href}} rel="stylesheet"></link>
              % end
              % js.each do |src|
                <script src={{src}} type="application/javascript" defer></script>
              % end
            </head>
            <body>
              <nav>
                <a href={{path :Home, :index}}>Home</a>
              </nav>
              ${content}
            </body>
          </html>
          <html
          RB
        )
        File.write(
          File.join(dir, "app.rb"),
          <<~RB
          require "yescode"

          require_all %w[
            ./app/modules/*
            ./app/models/*
            ./app/emails/*
            ./app/jobs/*
            ./app/views/layout
            ./app/views/*
            ./app/controllers/*
            ./app/routes
          ]

          class App < YesApp
            logger YesLogger.new($stdout)

            use YesStatic, root: "public" if development?
            use YesRackLogger
            use Rack::ShowExceptions if development?
            use Rack::Runtime
            use Rack::ETag
            use Rack::Head
            use Rack::ContentLength
            use Rack::ContentType
            use Rack::Session::Cookie, default_session_cookie
            use YesCsrf, raise: development?

            css %w[]

            js %w[]

            migrations "db/migrations/*.sql"

            routes :Routes

            if production?
              migrate
              bundle_static_files
            end
          end
          RB
        )
        File.write(
          File.join(dir, ".env"),
          <<~SH
          RACK_ENV=development
          PORT=9292
          SECRET=#{SecureRandom.hex(32)}
          DATABASE_URL=development.sqlite3
          SH
        )
        # .env
        # Gemfile
        # Gemfile.lock
        # Dockerfile
        # Procfile
        # config.ru
        # public/
        # public/404.html
        # public/500.html
        # public/js
        # public/css
        # db/
        # db/migrations
        # app/
        # app/models
        # app/views
        # app/controllers
        # app/jobs
        # app/modules
        # app/emails
        # app/routes.rb
        # app.rb
      end

      def generate_mvc(filename = nil)
        if filename.nil?
          puts MVC_HELP_MESSAGE
          return
        end

        generate_model(filename)
        generate_controller(filename)
        generate_views(filename)
      end

      def generate_queries(filename = nil)
        if filename.nil?
          puts QUERIES_HELP_MESSAGE
          return
        end

        filepath = File.join(".", "app", "models", "#{filename}.sql")
        contents = <<~SQL
        -- name: all
        select *
        from #{filename}

        -- name: count
        -- fn: value
        select count(*)
        from #{filename}

        -- name: by_#{filename}_id
        select *
        from #{filename}
        where #{filename}_id = ?

        -- name: latest
        select *
        from #{filename}
        order by created_at desc

        -- name: oldest
        select *
        from #{filename}
        order by created_at

        -- name: latest_with_limit
        select *
        from #{filename}
        order by created_at desc
        limit 30
        SQL

        File.write(filepath, contents)
      end

      def generate_model(filename = nil)
        if filename.nil?
          puts MODEL_HELP_MESSAGE
          return
        end

        filepath = File.join(".", "app", "models", "#{filename}.rb")
        class_name = pascal_case(filename)
        contents = <<~RB
        class #{class_name} < YesRecord
          define_queries "#{filename}.sql"
        end
        RB
        File.write(filepath, contents)

        generate_migration("create_table_#{filename}")
        generate_queries(filename)
      end

      def generate_controller(filename = nil)
        if filename.nil?
          puts CONTROLLER_HELP_MESSAGE
          return
        end

        class_name = pascal_case(filename)
        var_name = filename
        route = <<~RB
        class #{class_name} < YesController
          def index
            all = #{class_name}.all

            #{class_name}Index.new(all)
          end

          def show
            #{class_name}Show.new(#{var_name})
          end

          def new
            @#{var_name} ||= #{class_name}.new

            #{class_name}New.new(@#{var_name})
          end

          def create
            @#{var_name} = #{class_name}.new(#{var_name}_params)

            if @#{var_name}.insert
              redirect path(:#{class_name}, :index)
            else
              new
            end
          end

          def edit
            #{class_name}Edit.new(#{var_name})
          end

          def update
            if #{var_name}.update(#{var_name}_params)
              redirect path(:#{class_name}, :index)
            else
              edit
            end
          end

          def delete
            #{var_name}.delete

            redirect path(:#{class_name}, :index)
          end

          private

          def #{var_name}_params
            params.slice()
          end

          def #{var_name}
            @#{var_name} ||= #{class_name}.first! :by_#{var_name}_id, params[:#{var_name}_id]
          end
        end
        RB

        File.write(
          File.join(".", "app", "controllers", "#{filename}.rb"),
          route
        )

        routes_filename = File.join(".", "app", "routes.rb")
        routes_file = File.read(routes_filename)
        idx = routes_file.rindex(/end/)
        routes_file.insert(idx, "\n  resource \"/#{filename}\", :#{class_name}\n")

        File.write routes_filename, routes_file
      end

      def generate_view(filename = nil, accessors = [])
        if filename.nil?
          puts VIEW_HELP_MESSAGE
          return
        end

        class_name = pascal_case(filename)
        filepath = File.join(VIEW_DIR, "#{filename}.rb")

        return if File.exist?(filepath)

        view = <<~RB
        class #{class_name} < Layout
          view "#{filename}.emote"
          attr_accessor #{accessors.map { |a| ":#{a}" }.join(', ')}

          def initialize(#{accessors.join(', ')})
            #{accessors.map { |a| "@#{a} = #{a}" }.join("\n")}
          end
        end
        RB
        File.write(filepath, view)

        generate_template(filename)
      end

      def generate_views(prefix)
        if prefix.nil?
          puts VIEWS_HELP_MESSAGE
          return
        end

        %w[new show edit index].each do |suffix|
          generate_view("#{prefix}_#{suffix}", [])
        end
      end

      def generate_template(filename = nil)
        if filename.nil?
          puts TEMPLATE_HELP_MESSAGE
          return
        end

        filename = File.join(VIEW_DIR, "#{filename}.emote")

        return if File.exist?(filename)

        File.write(filename, "<div></div>")
      end

      def generate_templates(prefix = nil)
        if prefix.nil?
          puts TEMPLATES_HELP_MESSAGE
          return
        end

        %w[index new edit show form].each do |page|
          generate_template("#{prefix}_#{page}")
        end
      end

      def generate_migration(filename = nil, columns = [])
        if filename.nil?
          puts MIGRATION_HELP_MESSAGE
          return
        end
        table_name = filename.split('_').last
        column_string = columns.map do |c|
          name, type = c.split(':')

          "#{name} #{type}"
        end.join(",\n  ")

        sql = <<~SQL
        -- name: up
        create table #{table_name} (
          #{table_name}_id integer primary key,
          #{column_string}
          created_at integer not null default(strftime('%s', 'now')),
          updated_at integer
        )

        -- name: down
        drop table #{table_name}
        SQL

        sql = "-- name: up\n\n-- name: down" unless filename.start_with?("create_table")

        filename = "#{Time.now.to_i}_#{filename}"
        filepath = File.join(".", "db", "migrations", "#{filename}.sql")

        puts "Writing file #{filepath}"
        File.write(filepath, sql)
      end
    end
  end
end
