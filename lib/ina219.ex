defmodule INA219 do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(INA219.Device, [])
    ]

    opts = [strategy: :simple_one_for_one, name: INA219.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    bus     = Application.get_env(:ina219, :bus)
    address = Application.get_env(:ina219, :address)
    config  = Application.get_env(:ina219, :config, [])
    if (bus && address), do: connect(bus, address, config)

    {:ok, sup}
  end

  def connect(bus, address, config \\ []) do
    Supervisor.start_child(INA219.Supervisor, [bus, address, config])
  end
end
