defmodule INA219.Device do
  use GenServer
  alias INA219.{Device, Commands}
  require Logger

  def start_link(%{bus: _, address: _}=config) do
    GenServer.start_link(Device, [config])
  end

  @doc """
  Executes the passed function with the `pid` of the I2C connection as it's argument.
  Use this if you want to manually run functions from `Commands` or `Registers`.
  """
  def execute(fun) when is_function(fun), do: GenServer.call(gproc_pid(:default), {:execute, fun})
  def execute(bus, address, fun) when is_function(fun), do: GenServer.call(gproc_pid(bus, address), {:execute, fun})

  @doc """
  Gets and sets the value of the current divisor currently set for this device.
  """
  def current_divisor, do: GenServer.call(gproc_pid(:default), :current_divisor)
  def current_divisor(bus, address), do: GenServer.call(gproc_pid(bus, address), :current_divisor)
  def current_divisor(n) when is_number(n), do: GenServer.call(gproc_pid(:default), {:current_divisor, n})
  def current_divisor(bus, address, n) when is_number(n), do: GenServer.call(gproc_pid(bus, address), {:current_divisor, n})

  @doc """
  Gets and sets the value of the power divisor currently set for this device.
  """
  def power_divisor, do: GenServer.call(gproc_pid(:default), :power_divisor)
  def power_divisor(bus, address), do: GenServer.call(gproc_pid(bus, address), :power_divisor)
  def power_divisor(n) when is_number(n), do: GenServer.call(gproc_pid(:default), {:power_divisor, n})
  def power_divisor(bus, address, n) when is_number(n), do: GenServer.call(gproc_pid(bus, address), {:power_divisor, n})

  @doc """
  Are new samples ready since the last time you read them?
  Calling this function will clear the value until next time new samples are ready.
  """
  def conversion_ready?, do: GenServer.call(gproc_pid(:default), :conversion_ready?)
  def conversion_ready?(bus, address), do: GenServer.call(gproc_pid(bus, address), :conversion_ready?)

  @doc """
  Returns `true` when power or current calculations are out of range.
  This indicates that current and power data may be meaningless.
  """
  def math_overflow?, do: GenServer.call(gproc_pid(:default), :math_overflow?)
  def math_overflow?(bus, address), do: GenServer.call(gproc_pid(bus, address), :math_overflow?)

  @doc """
  Returns the bus voltage in mV.
  """
  def bus_voltage, do: GenServer.call(gproc_pid(:default), :bus_voltage)
  def bus_voltage(bus, address), do: GenServer.call(gproc_pid(bus, address), :bus_voltage)

  @doc """
  Returns the shunt voltage in mV.
  """
  def shunt_voltage, do: GenServer.call(gproc_pid(:default), :shunt_voltage)
  def shunt_voltage(bus, address), do: GenServer.call(gproc_pid(bus, address), :shunt_voltage)

  @doc """
  Returns the current in mA.
  """
  def current, do: GenServer.call(gproc_pid(:default), :current)
  def current(bus, address), do: GenServer.call(gproc_pid(bus, address), :current)

  @doc """
  Returns the power in mW
  """
  def power, do: GenServer.call(gproc_pid(:default), :power)
  def power(bus, address), do: GenServer.call(gproc_pid(bus, address), :power)

  @doc """
  Disconnects from the I2C device and terminates the Device proces.
  """
  def disconnect(reason \\ :normal), do: GenServer.stop(gproc_pid(:default), reason)
  def disconnect(bus, address, reason \\ :normal), do: GenServer.stop(gproc_pid(bus, address), reason)

  def init([%{bus: bus, address: address}=config]) do
    gproc_reg(bus, address)
    Logger.info("Connecting to INA219 device #{device_name bus, address}")
    {:ok, pid} = I2c.start_link(bus, address)

    commands        = Map.get(config, :commands, [])
    current_divisor = Map.get(config, :current_divisor, 1)
    power_divisor   = Map.get(config, :power_divisor, 1)

    with :ok <- Commands.reset!(pid),
         :ok <- apply_commands(pid, commands)
    do
      state = %{
        bus:             bus,
        address:         address,
        commands:        commands,
        current_divisor: current_divisor,
        power_divisor:   power_divisor,
        i2c:             pid
      }
      {:ok, state}
    else
      {:error, message} -> {:stop, message}
    end
  end

  def terminate(_reason, %{i2c: pid}=state) do
    Logger.info("Disconnecting from INA219 device #{device_name state}")
    I2c.release(pid)
  end

  def handle_call({:execute, fun}, _from, %{i2c: pid}=state) do
    result = fun.(pid)
    {:reply, result, state}
  end

  def handle_call(:current_divisor, _from, %{current_divisor: divisor}=state) do
    {:reply, divisor, state}
  end

  def handle_call({:current_divisor, divisor}, _from, state) do
    {:reply, :ok, %{state | current_divisor: divisor}}
  end

  def handle_call(:power_divisor, _from, %{power_divisor: divisor}=state) do
    {:reply, divisor, state}
  end

  def handle_call({:power_divisor, divisor}, _from, state) do
    {:reply, :ok, %{state | power_divisor: divisor}}
  end

  def handle_call(:conversion_ready?, _from, %{i2c: pid}=state) do
    {:reply, Commands.conversion_ready?(pid), state}
  end

  def handle_call(:math_overflow?, _from, %{i2c: pid}=state) do
    {:reply, Commands.math_overflow?(pid), state}
  end

  def handle_call(:bus_voltage, _from, %{i2c: pid}=state) do
    {:reply, Commands.bus_voltage(pid), state}
  end

  def handle_call(:shunt_voltage, _from, %{i2c: pid}=state) do
    {:reply, Commands.shunt_voltage(pid), state}
  end

  def handle_call(:current, _from, %{i2c: pid, current_divisor: divisor}=state) do
    {:reply, Commands.current(pid, divisor), state}
  end

  def handle_call(:power, _from, %{i2c: pid, power_divisor: divisor}=state) do
    {:reply, Commands.power(pid, divisor), state}
  end

  defp apply_commands(pid, commands) do
    Enum.reduce(commands, :ok, fn
      _, {:error, _}=error
        -> error
      command, :ok when is_atom(command) ->
        apply(Commands, command, [pid])
      {command, args}, :ok when is_atom(command) and is_list(args) ->
        apply(Commands, command, [pid | args])
      {command, arg}, :ok when is_atom(command) ->
        apply(Commands, command, [pid, arg])
    end)
  end

  defp device_name(%{bus: bus, address: address}), do: device_name(bus, address)
  defp device_name(bus, address), do: "#{bus}:#{i2h address}"
  defp i2h(i), do: "0x" <> Integer.to_string(i, 16)

  defp gproc_key(bus, address), do: {:n, :l, {Device, bus, address}}
  defp gproc_pid(:default) do
    :ina219
    |> Application.get_env(:devices, [])
    |> Enum.take(1)
    |> Enum.map(fn %{bus: bus, address: address} -> gproc_pid(bus, address) end)
    |> List.first
  end
  defp gproc_pid(bus, address), do: :gproc.lookup_pid(gproc_key(bus, address))
  defp gproc_reg(bus, address), do: :gproc.reg(gproc_key(bus, address))
end