defmodule INA219.Registers do
  use Bitwise
  require Logger

  def configuration(pid), do: read_register(pid, 0)
  def configuration(pid, bytes), do: write_register(pid, 0, bytes)

  def shunt_voltage(pid), do: read_register(pid, 1)

  def bus_voltage(pid), do: read_register(pid, 2)

  def power(pid), do: read_register(pid, 3)

  def current(pid), do: read_register(pid, 4)

  def calibration(pid), do: read_register(pid, 5)
  def calibration(pid, bytes), do: write_register(pid, 5, bytes)

  defp read_register(pid, register) do
    with :ok                           <- I2c.write(pid, <<register>>),
         << value::integer-size(16) >> <- I2c.read(pid, 2),
     do: inspect_bytes("Read", value)
  end

  defp write_register(pid, register, bytes) do
    inspect_bytes("Write", bytes)
    msb = bytes >>> 8
    lsb = bytes &&& 0xff
    I2c.write(pid, <<register, msb, lsb>>)
  end

  defp inspect_bytes(action, bytes) do
    Logger.debug(fn ->
      bits = bytes
        |> Integer.to_string(2)
        |> String.split("")
        |> Enum.reject(fn i -> i == "" end)
        |> lpad
        |> Enum.join("  ")

      "#{action} #{bytes}:\n" <>
      "15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0\n " <>
      bits
    end)
    bytes
  end

  defp lpad(bits) when length(bits) < 16 do
    lpad [ "0" | bits ]
  end
  defp lpad(bits), do: bits

end