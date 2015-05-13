defmodule FileWatcher do
  use GenServer
  
  @name FileWatcher
  @folder_rescan_interval 500

  @flag_defaults [
    allow_dir: false,
    allow_hidden: false,
    recursive: false]

  @doc """
  Convenience method for starting the file watcher
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name) 
  end
  
  @doc """
  Starts the FileWatcher server as initially containing no watched folders
  """
  def init(_args) do
    {:ok, []}
  end
  
  def watch_folder(server, folder_path, flags, callback) do
    GenServer.call(server, {:watch_folder, folder_path, flags, callback})
  end

  @doc """
  Adds a folder to the list of folders being watched, with a callback
  that executes on added files
  """
  def handle_call({:watch_folder, folder_path, flags, callback}, _from, state) do
    monitor_pid = spawn fn ->
      parent = self()
      spawn fn -> 
        scan_forever(parent, folder_path, flags) 
      end
      wait_for_changes(folder_path, callback)
    end
    reply = {:ok, %{monitor: monitor_pid}}
    {:reply, reply, [folder_path | state]}
  end

  defp wait_for_changes(folder_path, callback) do
    receive do
      new_files ->
        callback.(new_files)
    end
    
    wait_for_changes(folder_path, callback)
  end

  defp get_flag(keyword_list, flag) do
    Keyword.get(keyword_list, flag, Keyword.fetch!(@flag_defaults, flag))
  end

  defp ls(path, flags) do
    d = get_flag(flags, :allow_dir)
    a = get_flag(flags, :allow_hidden)

    {:ok, files} = File.ls(path)

    for file <- files,
      d == (File.dir?(file |> Path.expand(path))),
      a == (String.first(Path.basename(file)) == '.') do
      file
    end
  end

  def scan_forever(parent, folder_path, flags) do
    # Initial scan of files, so that existing files are considered 'added'
    files = ls(folder_path, flags)

    # Start looping
    scan_forever(parent, folder_path, files, flags)
  end

  defp scan_forever(parent, folder_path, old_files, flags) do
    files = ls(folder_path, flags)
    
    new_files = Enum.filter(files, &(!(&1 in old_files)))
    if [] != new_files do
      send(parent, new_files |> Enum.map(&(Path.join(folder_path,&1))))
    end
    
    :timer.sleep @folder_rescan_interval
    scan_forever(parent, folder_path, files, flags)
  end
  
end
