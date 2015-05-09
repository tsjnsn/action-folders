defmodule AF.Actions do
  
  @doc """
  Takes a filename and determines what script to run, based on the OS.
  Then executes the script as a command to which the filename is passed
  as an argument.
  """
  def act(filename, command, cd) do
    fullfilename = filename |> Path.expand
    
    [cmd | cmdargs] = String.split command
    args = cmdargs ++ [ fullfilename ]

    IO.inspect [command: cmd, arguments: args]
   
    case System.cmd(cmd, args) do
      {output, 0} -> {:ok, output}
      {output, err} -> {:error, output, err}
    end
  end
  
end
