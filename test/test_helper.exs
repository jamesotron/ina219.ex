defmodule FakeI2C do
  use GenServer

  def start_link, do: GenServer.start_link(FakeI2C, [])

  def init([]), do: {:ok, {0, []}}

  def flush(pid), do: GenServer.call(pid, :__flush)
  def set_response(pid, response), do: GenServer.cast(pid, {:__set_response, response})

  def handle_call({:write, _}=msg, _from, {resp, messages}) do
    {:reply, :ok, {resp, [msg | messages]}}
  end

  def handle_call(:__flush, _from, {_, messages}) do
    {:stop, :normal, Enum.reverse(messages), nil}
  end

  def handle_call(message, _from, {resp, messages}) do
    {:reply, resp, {resp, [message | messages]}}
  end

  def handle_cast({:__set_response, response}, {_, messages}) do
    {:noreply, {response, messages}}
  end

  def handle_cast(message, {resp, messages}) do
    {:noreply, {resp, [message | messages]}}
  end
end

ExUnit.start()
