defmodule INA219.CommandsTest do
  use ExUnit.Case, async: true
  alias INA219.Commands

  test "reset!" do
    {:ok, pid} = FakeI2C.start_link

    Commands.reset!(pid)

    assert [write: <<0>>, read: 2, write: <<0, 0x80, 0>>] = FakeI2C.flush(pid)
  end

  test "read bus voltage range" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0b1101111111111111)
    assert 16 == Commands.bus_voltage_range(pid)

    FakeI2C.set_response(pid, 0b0010000000000000)
    assert 32 == Commands.bus_voltage_range(pid)

    FakeI2C.flush(pid)
  end

  test "set bus voltage range to 16V" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok == Commands.bus_voltage_range(pid, 16)

    assert [write: <<0>>, read: 2, write: <<0, 0b11011111, 0xff>>] == FakeI2C.flush(pid)
  end

  test "set bus voltage range to 32V" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0)
    assert :ok == Commands.bus_voltage_range(pid, 32)

    assert [write: <<0>>, read: 2, write: <<0, 0b00100000, 0>>] == FakeI2C.flush(pid)
  end

  test "read shunt voltage PGA" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0)
    assert 1 == Commands.shunt_voltage_pga(pid)

    FakeI2C.set_response(pid, 0b0000100000000000)
    assert 2 == Commands.shunt_voltage_pga(pid)

    FakeI2C.set_response(pid, 0b0001000000000000)
    assert 4 == Commands.shunt_voltage_pga(pid)

    FakeI2C.set_response(pid, 0b0001100000000000)
    assert 8 == Commands.shunt_voltage_pga(pid)

    FakeI2C.flush(pid)
  end

  test "set shunt voltage PGA gain to 1" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_voltage_pga(pid, 1)

    assert [write: <<0>>, read: 2, write: <<0, 0b11100111, 0xff>>] = FakeI2C.flush(pid)
  end

  test "set shunt voltage PGA gain to +2" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_voltage_pga(pid, 2)

    assert [write: <<0>>, read: 2, write: <<0, 0b11101111, 0xff>>] = FakeI2C.flush(pid)
  end

  test "set shunt voltage PGA gain to +4" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_voltage_pga(pid, 4)

    assert [write: <<0>>, read: 2, write: <<0, 0b11110111, 0xff>>] = FakeI2C.flush(pid)
  end

  test "set shunt voltage PGA gain to +8" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_voltage_pga(pid, 8)

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0xff>>] = FakeI2C.flush(pid)
  end

  test "read bus ADC resolution and averaging" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0b1111100001111111)
    assert {1, 9} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111100011111111)
    assert {1, 10} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111100101111111)
    assert {1, 11} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111100111111111)
    assert {1, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111101001111111)
    assert {1, 9} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111101011111111)
    assert {1, 10} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111101101111111)
    assert {1, 11} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111101111111111)
    assert {1, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111110001111111)
    assert {1, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111110011111111)
    assert {2, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111110101111111)
    assert {4, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111110111111111)
    assert {8, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111001111111)
    assert {16, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111011111111)
    assert {32, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111101111111)
    assert {64, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111111111)
    assert {128, 12} == Commands.bus_adc_resolution_and_averaging(pid)

    FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {1, 9}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {1, 9})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111000, 0b01111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {1, 10}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {1, 10})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111000, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {1, 11}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {1, 11})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111001, 0b01111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {1, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {1, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111001, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {2, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {2, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111100, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {4, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {4, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111101, 0b01111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {8, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {8, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111101, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {16, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {16, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111110, 0b01111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {32, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {32, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111110, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {64, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {64, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b01111111 >>] = FakeI2C.flush(pid)
  end

  test "set bus ADC resolution and averaging {128, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.bus_adc_resolution_and_averaging(pid, {128, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "read shunt ADC resolution and averaging" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0b1111111110000111)
    assert {1, 9} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110001111)
    assert {1, 10} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110010111)
    assert {1, 11} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110011111)
    assert {1, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110100111)
    assert {1, 9} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110101111)
    assert {1, 10} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110110111)
    assert {1, 11} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111110111111)
    assert {1, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111000111)
    assert {1, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111001111)
    assert {2, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111010111)
    assert {4, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111011111)
    assert {8, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111100111)
    assert {16, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111101111)
    assert {32, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111110111)
    assert {64, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.set_response(pid, 0b1111111111111111)
    assert {128, 12} == Commands.shunt_adc_resolution_and_averaging(pid)

    FakeI2C.flush(pid)
  end


  test "set shunt ADC resolution and averaging {1, 9}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {1, 9})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b10000111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {1, 10}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {1, 10})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b10001111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {1, 11}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {1, 11})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b10010111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {1, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {1, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b10011111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {2, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {2, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11001111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {4, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {4, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11010111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {8, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {8, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11011111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {16, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {16, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11100111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {32, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {32, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11101111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {64, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {64, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11110111 >>] = FakeI2C.flush(pid)
  end

  test "set shunt ADC resolution and averaging {128, 12}" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.shunt_adc_resolution_and_averaging(pid, {128, 12})

    assert [write: <<0>>, read: 2, write: <<0, 0b11111111, 0b11111111 >>] = FakeI2C.flush(pid)
  end

  test "read mode" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xff00)
    assert :power_down = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff01)
    assert :shunt_voltage_triggered = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff02)
    assert :bus_voltage_triggered = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff03)
    assert :adc_off = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff04)
    assert :shunt_voltage_continuous = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff05)
    assert :bus_voltage_continuous = Commands.mode(pid)

    FakeI2C.set_response(pid, 0xff06)
    assert :shunt_and_bus_voltage_continuous = Commands.mode(pid)

    FakeI2C.flush(pid)
  end

  test "set mode to :power_down" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :power_down)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111000>>] = FakeI2C.flush(pid)
  end

  test "set mode to :shunt_voltage_triggered" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :shunt_voltage_triggered)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111001>>] = FakeI2C.flush(pid)
  end

  test "set mode to :bus_voltage_triggered" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :bus_voltage_triggered)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111010>>] = FakeI2C.flush(pid)
  end

  test "set mode to :adc_off" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :adc_off)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111011>>] = FakeI2C.flush(pid)
  end

  test "set mode to :shunt_voltage_continuous" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :shunt_voltage_continuous)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111100>>] = FakeI2C.flush(pid)
  end

  test "set mode to :bus_voltage_continuous" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :bus_voltage_continuous)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111101>>] = FakeI2C.flush(pid)
  end

  test "set mode to :shunt_and_bus_voltage_continuous" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0xffff)
    assert :ok = Commands.mode(pid, :shunt_and_bus_voltage_continuous)

    assert [write: <<0>>, read: 2, write: <<0, 0xff, 0b11111110>>] = FakeI2C.flush(pid)
  end

  test "read conversion ready?" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0b1111111111111101)
    assert false == Commands.conversion_ready?(pid)

    FakeI2C.set_response(pid, 0b0000000000000010)
    assert true == Commands.conversion_ready?(pid)

    FakeI2C.flush(pid)
  end

  test "read math overflow?" do
    {:ok, pid} = FakeI2C.start_link

    FakeI2C.set_response(pid, 0b1111111111111110)
    assert false == Commands.math_overflow?(pid)

    FakeI2C.set_response(pid, 0b0000000000000001)
    assert true == Commands.math_overflow?(pid)

    FakeI2C.flush(pid)
  end
end