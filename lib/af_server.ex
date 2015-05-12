defmodule AF.Folder do
  defstruct path: "", command: "", flags: []

  def recursive?(af) do
    :recursive in af.flags
  end
end

defmodule AF.Server do
  use GenServer
  require Logger
  
  def start_link(opts \\ []) do
    args = opts
    GenServer.start_link(__MODULE__, args, opts)
  end

  @doc """
  Initialize the ActionFolders GenServer with the default values
  """
  def init(args) do
    Logger.debug "AF.Server started with args:\n#{inspect args, [pretty: true]}"

    { :ok, watcher } = FileWatcher.start_link([])

    folders = Keyword.get(args, :folders, [])

    { :ok, %{ :folders => folders, :watcher => watcher } }
  end

  @doc """
  Adds a folder to the list of folders currently being monitored.
  """
  def watch(server, path, command, flags) do
    GenServer.call(server, {:watch_folder, path: path, command: command, flags: flags})
  end
  
  @doc """
  Returns a list of all folders currently being monitored.
  """
  def list_action_folders(server) do
    GenServer.call(server, :list_action_folders)
  end

  @doc """
  Set the base folder for the ActionFolders server. It will attempt
  to expand the given path first.
  
  If successful, returns {:ok, "path/to/folder"}
  otherwise it returns a {:error, "reason"}
  """
  def handle_call({:watch_folder, path: folder_path, command: command, flags: flags}, _from, state) 
  do
    IO.inspect state
    new_folder = %AF.Folder{path: folder_path, command: command, flags: flags}
    new_state = %{state | :folders => [new_folder | state.folders] }
    
    callback = fn new_files ->
      IO.write "New files found: "; IO.inspect new_files
      for file <- new_files do
        spawn fn -> AF.Actions.act(file, command, AF.Config.default_path |> Path.dirname) end
      end
    end
    
    action_folders = get_action_folders(folder_path, flags)
    
    for folder <- action_folders do
      {:ok, _reply} = FileWatcher.watch_folder(state.watcher, folder, flags, callback)
    end
    
    {:reply, folder_path, new_state}
  end

  @doc """
  Returns a list of action folders contained in the base folder.
  Searches all subfolders.
  """
  def handle_call(:list_action_folders, _from, state) do

    list_af_folders = fn folder -> 
      get_action_folders(folder.path, AF.Folder.recursive?(folder)) 
    end
    
    folders = Enum.map(state.folders, list_af_folders) |> List.flatten
    
    {:reply, folders, state}
  end
  
  # Helper method for get_action_folders. Just lists all folders,
  # including sub folders in a directory.
  # The returned list is not automatically flattened, so there could
  # be nested lists

  defp get_directories(path, recursive) when recursive==false do
    [ path ]
  end
  
  defp get_directories(path, recursive) when recursive==true do
    here = get_directories(path, false) 
    
    subfolders =
    path
    |> File.ls!
    |> Enum.map(&(Path.join(path,&1))) 
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&get_directories(&1, recursive))

    here ++ subfolders
  end
  
  
  @doc """
  Can call on any directory to get the list of action folders
  """
  def get_action_folders(path, flags) do
    get_directories(path, Keyword.fetch!(flags, :recursive))
  end
  
end


