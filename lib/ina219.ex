defmodule INA219 do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(INA219.Device, [], restart: :transient)
    ]

    opts = [strategy: :simple_one_for_one, name: INA219.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    Enum.each(Application.get_env(:ina219, :devices, []), &connect(&1))

    {:ok, sup}
  end

  def connect(%{bus: _, address: _}=config) do
    Supervisor.start_child(INA219.Supervisor, [config])
  end
end
