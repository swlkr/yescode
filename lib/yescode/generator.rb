# frozen_string_literal: true

module Yescode
  class Generator
    INVALID_COMMAND_MESSAGE = "Command not supported. Try g, gen, generate, migrate or rollback."
    VIEW_DIR = File.join(".", "app", "views")

    using Refinements

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
        when "migration"
          generate_migration(*args)
        when "mvc"
          generate_mvc(*args)
        when "app"
          generate_app(*args)
        else
          puts INVALID_COMMAND_MESSAGE
        end
      end

      def generate_app(dir)
        {
          "public" => %w[css js],
          "db" => %w[migrations],
          "app" => %w[models views controllers emails jobs modules]
        }.each do |k, v|
          v.each do |folder|
            FileUtils.mkdir_p(File.join(k, folder))
          end
        end
        File.write(
          File.join(dir, "Gemfile"),
          <<~RB
          source "https://rubygems.org"
          git_source(:github) { |repo| "https://github.com/#{repo}.git" }

          ruby "3.1.2"

          gem "falcon", "0.39.2"
          RB
        )
        File.write(
          File.join(dir, "Dockerfile"),
          <<-DOCKER
          FROM ruby:3.1.2-slim-bullseye

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
          File.join(dir, "config.ru"),
          "require \"./app\"\n\nrun App.freeze.app"
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
          <<-RB
          class Routes < YesRoutes
            get "/", :Home, :index
          end
          RB
        )
        File.write(
          File.join(dir, "app", "controllers", "home.rb"),
          <<-RB
          class Home < AppController
            def index
              HomeIndex.new
            end
          end
          RB
        )
        File.write(
          File.join(dir, "app", "views", "home_index.rb"),
          <<-RB
          class HomeIndex < Layout
          end
          RB
        )
        File.write(
          File.join(dir, "app", "views", "home_index.emote"),
          <<-RB
          <h1>Welcome to yescode!</h1>
          RB
        )
        File.write(
          File.join(dir, "app", "views", "layout.rb"),
          <<-RB
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
          <<-RB
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
      end

      def generate_mvc(filename)
        generate_model(filename)
        generate_controller(filename)
        generate_views(filename)
      end

      def generate_queries(filename)
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

      def generate_model(filename)
        filepath = File.join(".", "app", "models", "#{filename}.rb")
        class_name = filename.pascal_case
        contents = <<~RB
        class #{class_name} < AppRecord
          queries "#{filename}.sql"
        end
        RB
        File.write(filepath, contents)

        generate_migration("create_table_#{filename}")
        generate_queries(filename)
      end

      def generate_controller(filename)
        class_name = filename.pascal_case
        var_name = filename
        route = <<~RB
        class #{class_name} < AppController
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

      def generate_view(filename, accessors = [])
        class_name = filename.pascal_case
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
        %w[new show edit index].each do |suffix|
          generate_view("#{prefix}_#{suffix}", [])
        end
      end

      def generate_template(filename)
        filename = File.join(VIEW_DIR, "#{filename}.emote")

        return if File.exist?(filename)

        File.write(filename, "<div></div>")
      end

      def generate_templates(prefix)
        %w[index new edit show form].each do |page|
          generate_template("#{prefix}_#{page}")
        end
      end

      def generate_migration(filename, columns = [])
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
