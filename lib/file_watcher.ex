defmodule FileWatcher do
  use GenServer
  
  @folder_rescan_interval 500
  
  @doc """
  Starts the FileWatcher server as initially containing no watched folders
  """
  def init(args) do
    {:ok, []}
  end
  
  @doc """
  Adds a folder to the list of folders being watched, with a callback
  that executes on added files
  """
  def handle_call({:watch_folder, folder_path, _callback}, _from, state) do
    monitor_pid = spawn fn ->
      parent = self()
      spawn fn -> watch_folder(parent, folder_path) end
      monitor_folder(folder_path, _callback)
    end
    # watch_pid = spawn watch_folder(monitor_pid, folder_path)
    reply = {:ok, %{monitor: monitor_pid}}
    {:reply, reply, [folder_path | state]}
  end
  
  defp monitor_folder(folder_path, _callback) do
    receive do
      new_files ->
        _callback.(new_files)
    end
    
    monitor_folder(folder_path, _callback)
  end
  
  @doc """
  Watches a single directory for additional files every 0.5s
  """
  def watch_folder(parent, folder_path) do
    {:ok, files} = File.ls(folder_path)
    _watch_folder(parent, folder_path, files)
  end
  
  defp _watch_folder(parent, folder_path, old_files) do
    {:ok, files} = File.ls(folder_path)
    
    new_files = Enum.filter(files, &(!(&1 in old_files)))
    if [] != new_files do
      send(parent, new_files |> Enum.map(&(Path.join(folder_path,&1))))
    end
    
    :timer.sleep @folder_rescan_interval
    _watch_folder(parent, folder_path, files)
  end
  
end
