defmodule Tickex.Contracts.EventListener do
  @moduledoc """
  Provides a mechanism to listen to blockchain events, with the ability to specify filters and handling functions.
  This module allows customization of wait time and maximum attempts for event listening through options set in the `use` statement.
  """

  @callback handle_contract_event(
              event_response :: {:ok, [Ethers.Event.t()]} | {:error, atom()},
              event_name :: String.t()
            ) :: :continue | :halt

  alias __MODULE__

  @doc """
  Subscribes to a blockchain event with specified filtering and handling logic. This function should be called from
  the client module that `use`s `Tickex.Contracts.EventListener`. The `handle_contract_event/2` function must be implemented
  in the client module to define the event handling behavior.

  ## Parameters
  - `event_name`: The name of the event to subscribe to.
  - `filter_fun`: A function used to filter events.

  ## Examples
  To use this module, define `handle_contract_event/2` in your client module and set options via the `use` statement:

      defmodule MyModule do
        use Tickex.Contracts.EventListener, delay: 10000, max_attempts: 5

        def handle_contract_event({:ok, []}, _event_name), do: :continue

        def handle_contract_event({:ok, [event]}, "event_created") do
          IO.inspect(event)
          :halt
        end
      end

  Then, subscribe to an event as follows:

      MyModule.subscribe("event_created", filter_fun)
  """
  defmacro __using__(opts) do
    quote do
      def subscribe(event_name, filter_fun) do
        EventListener.subscribe(event_name, filter_fun, &handle_contract_event/2, unquote(opts))
      end
    end
  end

  def subscribe(event_name, filter_fun, handle_fun, opts) do
    Task.start(fn -> listen_for_events(event_name, filter_fun, handle_fun, opts, 0) end)
  end

  defp listen_for_events(:continue, event_name, filter_fun, handle_fun, opts, count) do
    delay = Keyword.get(opts, :delay, 5000)
    max_attempts = Keyword.get(opts, :max_attempts, 10)

    :timer.sleep(delay)

    if count < max_attempts do
      listen_for_events(event_name, filter_fun, handle_fun, opts, count + 1)
    end
  end

  defp listen_for_events(:halt, _event_name, _filter_fun, _handle_fun, _opts, _count), do: :ok

  defp listen_for_events(event_name, filter_fun, handle_fun, opts, count) do
    filter_fun
    |> Ethers.get_logs()
    |> handle_fun.(event_name)
    |> listen_for_events(event_name, filter_fun, handle_fun, opts, count)
  end
end
