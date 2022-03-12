defmodule Stenotype do
  alias Stenotype.Location

  require Logger

  defmacro __using__(_) do
    quote do
      require Logger

      import Stenotype,
        only: [
          info: 1,
          debug: 1,
          notice: 1,
          warn: 1,
          error: 1,
          to_s: 1,
          t: 1
        ]
    end
  end

  defmacro info(line) do
    loc = Location.register_log_location(__CALLER__, :info)

    quote do
      unquote(Macro.escape(loc))
      |> Stenotype.Format.log_line(unquote(line))
      |> Stenotype.Output.output(:info)
    end
  end

  defmacro debug(line) do
    loc = Stenotype.Location.register_log_location(__CALLER__, :debug)
    IO.inspect(Macro.to_string(line))

    quote do
      unquote(Macro.escape(loc))
      |> Stenotype.Format.log_line(unquote(line))
      |> Stenotype.Output.output(:debug)
    end
  end

  defmacro notice(line) do
    loc = Location.register_log_location(__CALLER__, :notice)

    quote do
      unquote(Macro.escape(loc))
      |> Stenotype.Format.log_line(unquote(line))
      |> Stenotype.Output.output(:notice)
    end
  end

  defmacro warn(line) do
    loc = Location.register_log_location(__CALLER__, :warn)

    quote do
      unquote(Macro.escape(loc))
      |> Stenotype.Format.log_line(unquote(line))
      |> Stenotype.Output.output(:warn)
    end
  end

  defmacro error(line) do
    loc = Location.register_log_location(__CALLER__, :error)

    quote do
      unquote(Macro.escape(loc))
      |> Stenotype.Format.log_line(unquote(line))
      |> Stenotype.Output.output(:error)
    end
  end

  defmacro to_s(term) do
    quote do
      Stenotype.Format.to_bin(unquote(term))
    end
  end

  def t(line \\ "") do
    with stack <- stack(),
         str_list <- Enum.map(stack, &Location.trace_string/1),
         lines <- Enum.join(str_list, "\n->"),
         do: Logger.warn("#{line}:\n->#{lines}")
  end

  defp stack() do
    with {_, list} <- Process.info(self(), :current_stacktrace) do
      # first stack is from Process
      list
      |> Enum.drop(1)
      |> Enum.filter(fn {mod, _, _, _} -> mod != __MODULE__ end)
      |> Enum.map(&Location.create/1)
    end
  end
end
