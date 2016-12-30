# INA219

A library for interacting with the [Texas Instruments INA219](http://www.ti.com/product/ina219?keyMatch=INA219&tisearch=Search-EN-Everything)
high side current and power monitoring chip via I2C  using [Elixir ALE](https://github.com/fhunleth/elixir_ale).

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

