defmodule AF.Folder do
  defstruct folder: "", command: "", args: [], flags: [recursive: false, 
    allow_dirs: false, allow_hidden: false]

  def recursive?(af) do
    Keyword.get(af.flags, :recursive, false)
  end
end

defmodule AF.Server do
  use GenServer
  require Logger

  @name AF.Server
  
  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  @doc """
  Initialize the ActionFolders GenServer with the default values
  """
  def init(args) do
    Logger.debug "AF.Server started with args:\n#{inspect args, [pretty: true]}"

    FileWatcher.start_link

    folders = Keyword.get(args, :folders, []) 
    for f <- folders do
      :ok = start_watching(f, &on_new_files(&1, f) )
    end

    { :ok, %{ :folders => folders } }
  end

  @doc """
  Adds a folder to the list of folders currently being monitored.
  """
  def watch(server, path, command, args \\ [], flags \\ []) do
    GenServer.call(server, {:watch_folder, path: path, command: command,
      args: args, flags: flags})
  end
  
  @doc """
  Returns a list of all folders currently being monitored.
  """
  def list_action_folders(server) do
    GenServer.call(server, :list_action_folders)
  end

  defp on_new_files(files, af) do
    Logger.info "New files found: #{inspect files}"
    for f <- files do
      spawn fn -> 
        AF.Utils.act(f, af.command, af.args, AF.Config.default_path |> Path.dirname)
      end
    end
  end

  defp start_watching(folder, callback) do
    dirs = dirs_for_folder(folder)
    for f <- dirs do
      {:ok, _} = FileWatcher.watch_folder(FileWatcher, f, folder.flags, callback)
    end
    :ok
  end

  @doc """
  Set the base folder for the ActionFolders server. It will attempt
  to expand the given path first.
  
  If successful, returns {:ok, "path/to/folder"}
  otherwise it returns a {:error, "reason"}
  """
  def handle_call({:watch_folder, 
    path: path,
    command: command,
    args: args,
    flags: flags}, _from, state) 
  do
    IO.inspect state

    new_folder = %AF.Folder{folder: path, command: command, args: args, flags: flags}
    :ok = start_watching(new_folder, &on_new_files(&1, command) )
    new_state = %{state | :folders => [new_folder | state.folders] }
    {:reply, path, new_state}
  end

  @doc """
  Returns a list of action folders contained in the base folder.
  Searches all subfolders.
  """
  def handle_call(:list_action_folders, _from, state) do
    {:reply, state.folders, state}
  end
  
  # Helper method for get_action_folders. Just lists all folders,
  # including sub folders in a directory.
  # The returned list is not automatically flattened, so there could
  # be nested lists

  def dirs_for_folder(folder) do
    get_directories(folder.folder, AF.Folder.recursive?(folder))
  end

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
  
end


