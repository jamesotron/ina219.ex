defmodule INA219.RegistersTest do
  use ExUnit.Case, async: true
  alias INA219.Registers

  test "read configuration register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.configuration(pid)

    assert [write: <<0>>, read: 2] == FakeI2C.flush(pid)
  end

  test "set configuration register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.configuration(pid, 0xffff)

    assert [write: <<0, 255, 255>>] == FakeI2C.flush(pid)
  end

  test "read shunt voltage register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.shunt_voltage(pid)

    assert [write: <<1>>, read: 2] == FakeI2C.flush(pid)
  end

  test "read bus voltage register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.bus_voltage(pid)

    assert [write: <<2>>, read: 2] == FakeI2C.flush(pid)
  end

  test "read power register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.power(pid)

    assert [write: <<3>>, read: 2] == FakeI2C.flush(pid)
  end

  test "read current register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.current(pid)

    assert [write: <<4>>, read: 2] == FakeI2C.flush(pid)
  end

  test "read calibration register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.calibration(pid)

    assert [write: <<5>>, read: 2] == FakeI2C.flush(pid)
  end

  test "set calibration register" do
    {:ok, pid} = FakeI2C.start_link

    Registers.calibration(pid, 0xffff)

    assert [write: <<5, 255, 255>>] == FakeI2C.flush(pid)
  end
end