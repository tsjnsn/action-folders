defmodule FileWatcher do
  use GenServer
  
  def init(args) do
    {:ok, []}
  end
  
  def handle_call({:watch_folder, folder_path, _callback}, _from, state) do
    monitor_pid = spawn fn ->
      parent = self()
      spawn fn -> watch_folder(parent, folder_path) end
      monitor_folder(folder_path, _callback)
    end
    # watch_pid = spawn watch_folder(monitor_pid, folder_path)
    reply = {:ok, %{monitor: monitor_pid}}
    {:reply, reply, state ++ folder_path}
  end
  
  defp monitor_folder(folder_path, _callback) do
    receive do
      new_files ->
        _callback.(new_files)
    end
    
    monitor_folder(folder_path, _callback)
  end
  
  def watch_folder(parent, folder_path) do
    {:ok, files} = File.ls(folder_path)
    _watch_folder(parent, folder_path, files)
  end
  
  def _watch_folder(parent, folder_path, old_files) do
    {:ok, files} = File.ls(folder_path)
    
    new_files = Enum.filter(files, &(!(&1 in old_files)))
    if [] != new_files do
      send(parent, new_files)
    end
    
    :timer.sleep 500
    _watch_folder(parent, folder_path, files)
  end
end
