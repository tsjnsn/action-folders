defmodule ActionFolders do
  use Application
  
  def start(_type, _args) do
    AF.Supervisor.start_link
  end
end

defmodule AF.Supervisor do
  use Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end
  
  @af_name AF.Server
  
  def init(:ok) do
    config = AF.Config.parse_default()

    children = [
      worker(AF.Server, [[name: @af_name, folders: config]])
    ]
    
    IO.puts "Starting supervision on #{@af_name}"
    supervise(children, strategy: :one_for_one)
    
  end
end
