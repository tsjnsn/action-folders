defmodule AF.Supervisor do
  use Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end
  
  @af_name AF.Server
  
  def init(:ok) do
    config = AF.Config.parse_default()

    children = [
      worker(FileWatcher, []),
      worker(AF.Server, [[folders: config]])
    ]
    
    IO.puts "Starting supervision on #{@af_name}"
    supervise(children, strategy: :one_for_one)
    
  end
end
