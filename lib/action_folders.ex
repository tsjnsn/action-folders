defmodule ActionFolders do
  use GenServer

  @doc """
  Initialize the ActionFolders GenServer with the default values
  """
  def init(args) do
    {:ok, %{:base => nil}}
  end

  @doc """
  Set the base folder for the ActionFolders server. It will attempt
  to expand the given path first.
  
  If successful, returns {:ok, "path/to/folder"}
  otherwise it returns a {:error, "reason"}
  """
  def handle_call({:set_root_action_folder, folder_arg}, _from, state) do
    
    folder = cond do
      String.valid?(folder_arg) -> Path.expand(folder_arg)
      true -> nil
    end
    
    reply = cond do
      is_nil(folder)
        -> {:error, "Path provided was not a valid string"}
      !File.exists?(folder)
        -> {:error, "Path provided does not point to a valid location"}
      !File.dir?(folder)
        -> {:error, "Path provided is not a directory"}
      true
        -> {:ok, folder}
    end
    
    case reply do
      {:ok, folder} -> {:reply, reply, %{state | :base => folder}}
      _             -> {:reply, reply, state}
    end
  end

  @doc """
  Returns a list of action folders contained in the base folder.
  Searches all subfolders.
  """
  def handle_call(:list_action_folders, _from, state) do
      {:reply, get_action_folders(state.base), state}
  end
  
  @doc """
  If the target folder is an action folder, this returns true
  """
  def is_action_folder(folder) do
    folder |> File.ls |> elem(1) |> Enum.member?(".act")
  end
  
  @doc """
  Helper method for get_action_folders. Just lists all folders,
  including sub folders in a directory.
  The returned list is not automatically flattened, so there could
  be nested lists
  """
  defp get_directories(path) do
    path 
    |> File.ls 
    |> elem(1) 
    |> Enum.map(&(Path.join(path,&1))) 
    |> Enum.filter(&File.dir?/1) 
    |> (fn dirs -> Enum.concat(dirs, Enum.map(dirs, &get_directories/1)) end).()
  end
  
  
  @doc """
  Can call on any directory to get the list of action folders
  Descends subdirectories as well.
  Returns a list of directories with a file named '.act'
  """
  def get_action_folders(path) do
    path 
    |> get_directories
    |> List.flatten
    |> Enum.filter(&is_action_folder/1)
  end
  
  # def handle_cast({:push, item}) do
  #     {:noreply, [item|state]}
  # end
end



defmodule Actions do
  
  @doc """
  Tries to execute a script. If it fails predictably, it
  will return {:error, reason}
  """
  def act_on_file(script, file) do
    try do
      case System.cmd(script, file) do
        {output, 0} -> {:ok, output}
        {output, err} -> {:error, output, err}
      end
    rescue
      e in ArgumentError -> {:error, e}
      e in ErlangError -> {:error, e}
    end
  end
  
end
