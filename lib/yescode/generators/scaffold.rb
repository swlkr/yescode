# frozen_string_literal: true

require "erb"
require "fileutils"

module Yescode
  module Generators
    class Scaffold
      include Strings

      HELP_MESSAGE = <<~TXT
        Usage:
          yescode scaffold TABLE_NAME [field[:type] field[:type]] [options]

        Options:
          --singluar SINGULAR                    Specify the singular version of the table / class name
          --plural PLURAL                        Specify the plural version of the table / class name

        Create a new migration, queries, model, routes and components for the given table

        Examples:
          yescode scaffold todo
          yescode scaffold todo name:text done_at:integer
          yescode scaffold todo name:text done_at:integer --plural todos

        This will generate a the following files:

          ./app/components/todo_index.rb
          ./app/components/todo_index.html.erb
          ./app/components/todo_show.rb
          ./app/components/todo_show.html.erb
          ./app/components/todo_create.rb
          ./app/components/todo_create.html.erb
          ./app/components/todo_update.rb
          ./app/components/todo_update.html.erb
          ./app/components/todo_delete.rb
          ./app/components/todo_form.rb
          ./app/components/todo_form.html.erb
          ./app/modules/todo_helper.rb
          ./app/models/todo.rb
          ./app/models/todo.sql
          ./db/migrations/{timestamp}_create_table_todo.sql

        It will update the following files:

          ./app/routes.rb

        with the lines:

          route "/todos", TodoIndex
          route "/todos/create", TodoCreate
          route "/todos/:todo_id", TodoShow
          route "/todos/:todo_id/update", TodoUpdate
          route "/todos/:todo_id/delete", TodoDelete
      TXT

      attr_accessor :columns, :name

      def initialize(args)
        @name = args[0]
        @columns = args[1..].select { |a| a.include?(":") && !a.start_with?("--") }.map { |a| a.split(":") }
        @options = {}
        args[1..].each_with_index do |arg, index|
          @options[arg.gsub("--", "")] = args[index + 1] if arg.start_with?("--")
        end
      end

      def call
        if @name.nil?
          puts HELP_MESSAGE
          return
        end

        components_dir = File.join(".", "app", "components")
        models_dir = File.join(".", "app", "models")
        migrations_dir = File.join(".", "db", "migrations")
        modules_dir = File.join(".", "app", "modules")

        FileUtils.mkdir_p(components_dir)
        FileUtils.mkdir_p(models_dir)
        FileUtils.mkdir_p(migrations_dir)
        FileUtils.mkdir_p(modules_dir)

        Dir.glob(File.join(__dir__, "scaffold", "**", "*.erb"), File::FNM_DOTMATCH).each do |file|
          erb = File.read(file)
          template = ERB.new(erb, trim_mode: "<>-")
          basename = File.basename(file).gsub(/.erb$/, "")
          parts = File.dirname(file).split(File::SEPARATOR)
          index = parts.index("app") || parts.index("db")
          pathname = parts[index..]
          filename = "#{var_name}#{basename}"
          filename = "#{Time.now.to_i}_create_table_#{var_name}.sql" if file.include?("migrations")
          output = File.join(".", *pathname, filename)

          File.write(output, template.result(binding))
        end

        # update app/routes.rb
        routes_filename = File.join(".", "app", "routes.rb")
        routes_rb = File.read(routes_filename)
        index = routes_rb.index("end")
        route_str = <<~RB
          #{'  '}route "/#{plural_var_name}", #{class_name}Index
          #{'  '}route "/#{plural_var_name}/create", #{class_name}Create
          #{'  '}route "/#{plural_var_name}/:#{var_name}_id", #{class_name}Show
          #{'  '}route "/#{plural_var_name}/:#{var_name}_id/update", #{class_name}Update
          #{'  '}route "/#{plural_var_name}/:#{var_name}_id/delete", #{class_name}Delete
        RB
        File.write(routes_filename, routes_rb.insert(index, "#{route_str}"))
      end

      def var_name
        snake_case(@name || @options["singular"])
      end

      def plural_var_name
        snake_case("#{@name}s" || @options["plural"])
      end

      def class_name
        pascal_case(var_name)
      end

      def plural_class_name
        pascal_case(plural_var_name)
      end
    end
  end
end
