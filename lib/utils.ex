defmodule AF.Utils do
  
  @doc """
  Takes a filename and determines what script to run, based on the OS.
  Then executes the script as a command to which the filename is passed
  as an argument.
  """
  def act(filename, command, args, cd) do
    fullfilename = filename |> Path.expand

    args = for c <- args do Path.expand(c, cd) end
      |> Enum.concat [fullfilename]

    IO.inspect [command: command, args: args]
   
    case System.cmd(command, args, [cd: cd]) do
      {output, 0} -> {:ok, output}
      {output, err} -> {:error, output, err}
    end
  end
  
end
