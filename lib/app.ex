defmodule ActionFolders do
  use Application
  
  def start(_type, _args) do
    AF.Supervisor.start_link
  end
end
