defmodule ActionFolders do
  use Application
  
  def start(_type, _args) do
    pid = AF.Supervisor.start_link
    
    config = AF.Config.parse_default()
    for fld <- config do
      IO.inspect fld
      AF.Server.watch(AF.Server, fld.folder, fld.command)
    end 
    
    pid
  end
end

defmodule AF.Supervisor do
  use Supervisor
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end
  
  @af_name AF.Server
  
  def init(:ok) do
    children = [
      worker(@af_name, [[name: @af_name]])
    ]
    
    IO.puts "Starting supervision on #{@af_name}"
    supervise(children, strategy: :one_for_one)
    
  end
end
