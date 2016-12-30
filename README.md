# INA219

A library for interacting with the [Texas Instruments INA219](http://www.ti.com/product/ina219?keyMatch=INA219&tisearch=Search-EN-Everything)
high side current and power monitoring chip via I2C  using [Elixir ALE](https://github.com/fhunleth/elixir_ale).

I'm using the [Adafruit INA219 breakout](https://www.adafruit.com/product/904) for prototyping, so am using
their calibrations straight from their Arduino library, but you can do the maths and calibrate it yourself
if you're using a different shunt resistor value.

## Usage

In your `config.exs` add the following:

```elixir
config :ina219,
  devices: [{"i2c-1", 0x41, [:calibrate_32V_2A!]}]
```

For each device you have connected you must set the `bus` and `address` values according to your system.
If you leave the `devices` config empty then no device processes will be started automatically, however you
can start them yourself using;

```elixir
INA219.connect("i2c-1", 0x41)
```

You can also disconnect using;

```elixir
INA219.disconnect("i2c-1", 0x41)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ina219` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ina219, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ina219` is started before your application:

    ```elixir
    def application do
      [applications: [:ina219]]
    end
    ```

