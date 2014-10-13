defmodule AF.Server do
  use GenServer

  @default_name AF.Server

  def start_link(folders \\ [], options \\ []) do
    # TODO: let the user define folders to be added initially
    GenServer.start_link(__MODULE__, nil, options)
  end

  @doc """
  Initialize the ActionFolders GenServer with the default values
  """
  def init(args) do
    {:ok, %{:folders => []}}
  end

  @doc """
  Set the base folder for the ActionFolders server. It will attempt
  to expand the given path first.
  
  If successful, returns {:ok, "path/to/folder"}
  otherwise it returns a {:error, "reason"}
  """
  def handle_call({:watch_folder, [path: folder_path, flags: flags]}, _from, state) 
  when is_bitstring(folder_path) and is_list(flags) do
    
    is_recursive = :recursive in flags
    
    reply = cond do
      is_nil(folder_path) ->
        {:error, "Path provided was not a valid string"}
      !File.exists?(folder_path) ->
        {:error, "Path provided does not point to a valid location"}
      !File.dir?(folder_path) ->
        {:error, "Path provided is not a directory"}
      true ->
        {:ok}
    end
    
    new_folder = AF.Folder.make(folder_path, flags)
    
    case reply do
      {:ok} -> {:reply, reply, %{state | :folders => [new_folder | state.folders] }}
      _     -> {:reply, reply, state}
    end
  end
  
  def handle_call({:watch_folder, [path: path]}, _from, state) when is_bitstring(path) do
    handle_call({:watch_folder, [path: path, flags: []] }, _from, state)
  end

  @doc """
  Returns a list of action folders contained in the base folder.
  Searches all subfolders.
  """
  def handle_call(:list_action_folders, _from, state) do

    list_af_folders = fn folder -> 
      get_action_folders(AF.Folder.get_path(folder), AF.Folder.recursive?(folder)) 
    end
    
    folders = Enum.map(state.folders, list_af_folders) |> List.flatten
    
    {:reply, folders, state}
  end
  
  @doc """
  If the target folder is an action folder, this returns true
  """
  def is_action_folder(folder) do
    folder |> File.ls |> elem(1) |> Enum.member?(".act")
  end
  

  # Helper method for get_action_folders. Just lists all folders,
  # including sub folders in a directory.
  # The returned list is not automatically flattened, so there could
  # be nested lists
  defp _get_directories(path) do
    path 
    |> File.ls 
    |> elem(1) 
    |> Enum.map(&(Path.join(path,&1))) 
    |> Enum.filter(&File.dir?/1) 
  end
  
  defp _get_directories_recursive(path) do
    path
    |> get_directories(false)
    |> (fn dirs -> Enum.concat(dirs, Enum.map(dirs, &_get_directories_recursive/1) ) end).()
  end
  
  defp get_directories(path, recursive \\ false) do
    case recursive do
      true  -> _get_directories_recursive(path)
      false -> _get_directories(path)
    end
  end
  
  @doc """
  Can call on any directory to get the list of action folders
  Descends subdirectories as well.
  Returns a list of directories with a file named '.act'
  """
  def get_action_folders(path, recursive \\ false) do
    path 
    |> get_directories(recursive)
    |> List.flatten
    |> Enum.filter(&is_action_folder/1)
  end
  
end


defmodule AF.Folder do
  def make(path, flags \\ []) do
    {path, flags}
  end
  
  def get_path(folder) do
    elem(folder, 0)
  end
  
  def get_flags(folder) do
    elem(folder, 1)
  end
  
  def recursive?(folder) do
    :recursive in get_flags(folder)
  end
end
