defmodule Ra do
  require Logger

  @doc """
  Defines the banner to use when showing the help.
  """
  defmacro banner(banner) do
    quote do
      @banner unquote(banner)
    end
  end

  @doc """
  Defines and describes a subcommand.

  You have do provide at least the `name` of the command as a string and the
  function `f` that shall be called when this command is given.

  Also you can provide an optional `description` which will be displayed when
  showing the help.

  The function `f` needs to accept a single argument, beeing a three-tuple:
  `{arguments, options, config}`.
  """
  defmacro command(name, description \\ "", f) do
    quote do
      @commands @commands ++ [{ unquote(to_string name), unquote(description) }]
      def _command([unquote(to_string name)|args], opts) do
        rc = Ra.RcFile.load(__MODULE__)
        {args, opts, rc} |> unquote(f)
      end
    end
  end

  @doc """
  Defines and describes an option.

  You have to provide at least the `name` of the option, also you can define
  its `type` (`:string` is assumed as a default) and also you can optionally
  provide an `description`, the description is shown when the help is printed.

  Remember, when you want to have a `description`, you also need to provide the
  `type`.

  `type` may be one of the following atoms:

  * `:string` if the options value is supposed to be a string (default)
  * `:integer` if the options value is supposed to be an integer
  * `:float` if the options value is supposed to be a float
  * `:boolean` if the option is meant to be an on/off-switch. One can use
    `--opt`/`--no-opt` syntax for them.
  """
  defmacro option(name, type \\ :string, description \\ "") do
    quote do
      @options Map.put(@options, unquote(name), { unquote(type), unquote(description) })
      @opt_dict Map.put(@opt_dict, unquote(name), unquote(type))
    end
  end

  defmacro rc_file(dict) do
    quote do
      @commands @commands ++ [{ "initrc", "Initialize the runtime configuration file." }]

      def init_rc, do: _init_rc(unquote(dict), Ra.RcFile.exist?(__MODULE__))

      def _init_rc(_, true), do: nil
      def _init_rc(d, _), do: Ra.RcFile.touch(d, __MODULE__)

      def _command(["initrc"|_], _), do: init_rc()
    end
  end

  @doc """
  **This macro is deprecated**: Reassembles all the stuff configured beforehand.

  This macro needs to be used last in the module, as of version 0.3.3 its
  functionality is applied automatically by using a before_compile hook. **As of
  version 0.4.0 this macro will be removed!**

  It is also responsible for creating the `run` function needed by Elixir.
  """
  defmacro parse do
    IO.warn("Explicit usage of Ra.parse/0 is deprecated. The macro will be removed in 0.4.0.", Macro.Env.stacktrace(__CALLER__))

    quote do
      @commands @commands ++ [{ "help", "View this help information." }]

      def _command(["help"|_], _), do: help()

      def _command(_, _) do
        IO.puts "Command unknown."
        help()
      end

      def help do
        IO.puts "#{@banner}\n"

        IO.puts "OPTIONS:\n"

        @options
        |> Map.keys
        |> Enum.map(&("  --#{to_string &1} [#{Map.get(@options, &1) |> elem(0) |> to_string}] - #{Map.get(@options, &1) |> elem(1) |> to_string}"))
        |> Enum.join("\n")
        |> IO.puts

        IO.puts "\nCOMMANDS:\n"

        @commands
        |> Enum.map(&("  #{elem(&1, 0)} - #{elem(&1, 1)}"))
        |> Enum.join("\n")
        |> IO.puts
      end

      def run(args) do
        opts = OptionParser.parse(args, strict: @opt_dict)
        _command(elem(opts, 1), elem(opts, 0))
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      @banner   ""
      @commands []
      @options  %{}
      @opt_dict %{}
    end
  end

end
