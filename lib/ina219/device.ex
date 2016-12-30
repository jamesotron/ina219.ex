defmodule INA219.Device do
  use GenServer
  alias INA219.{Device, Commands}
  require Logger

  def start_link(bus, address, config \\ []) do
    GenServer.start_link(Device, [bus, address, config], name: process_name(bus, address))
  end

  def device(pid), do: GenServer.call(pid, :device)

  def init([bus, address, config]) do
    Logger.debug("Connecting to device #{device_name bus, address}")
    {:ok, pid} = I2c.start_link(bus, address)
    {:ok, %{bus: bus, address: address, config: config, i2c: pid}}
  end

  def handle_call(:device, _from, %{i2c: pid}=state) do
    {:reply, pid, state}
  end

  defp process_name(bus, address), do: Module.concat(INA219.Device, device_name(bus, address))
  defp device_name(%{bus: bus, address: address}), do: device_name(bus, address)
  defp device_name(bus, address), do: "#{bus}:0x#{i2h address}"
  defp i2h(i), do: "0x" <> Integer.to_string(i, 16)

end