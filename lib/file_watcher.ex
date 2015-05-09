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
  def handle_call({:watch_folder, folder_path, flags, _callback}, _from, state) do
    monitor_pid = spawn fn ->
      parent = self()
      spawn fn -> watch_folder(parent, folder_path, flags) end
      monitor_folder(folder_path, _callback)
    end
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
  

  def ls(path, flags) do
    d = Keyword.fetch!(flags, :allow_dir)
    a = Keyword.fetch!(flags, :allow_hidden)

    {:ok, files} = File.ls(path)

    for file <- files,
      d == (File.dir?(file |> Path.expand(path))),
      a == (String.first(Path.basename(file)) == '.') do
      file
    end
  end

  @doc """
  Watches a single directory for additional files every 0.5s
  """
  def watch_folder(parent, folder_path, flags) do
    files = ls(folder_path, flags)
    watch_folder(parent, folder_path, files, flags)
  end
  
  defp watch_folder(parent, folder_path, old_files, flags) do
    files = ls(folder_path, flags)
    
    new_files = Enum.filter(files, &(!(&1 in old_files)))
    if [] != new_files do
      send(parent, new_files |> Enum.map(&(Path.join(folder_path,&1))))
    end
    
    :timer.sleep @folder_rescan_interval
    watch_folder(parent, folder_path, files, flags)
  end
  
end
