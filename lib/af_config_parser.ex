defmodule AF.Config.Folder do
  defstruct folder: "", command: ""
end

#defmodule AF.Config do
#  defstruct folders: []
#end

defmodule AF.Config do

  @command_regex ~r/\s*(?<rule>\S+)\s*("(?<dir>[^"]*)"|(?<dir2>\S*))\s*("(?<cmd>[^"]*)"|(?<cmd2>\S*))\s*/

  def parse_file(filename) do
    dir = Path.dirname(filename)

    filename
    |> read_in
    |> String.split("\n")
    |> convert_lines_to_structs(dir)
  end

  def read_in(filename) do
    {:ok, confstr} = File.read filename
    confstr
  end

  def convert_lines_to_structs(rawconf, relative_to) do
    for line <- rawconf, Regex.match?(@command_regex, line) do
      #OptionParser.parse(OptionParse.split(line))
      case Regex.named_captures(@command_regex, line) do
        %{"rule" => "folder", "dir" => dir, "dir2" => dir2, "cmd" => cmd, "cmd2" => cmd2} -> 
          folder = dir <> dir2 |> Path.expand(relative_to)
          command = cmd <> cmd2
          %AF.Config.Folder{folder: folder, command: command}
        _ -> nil
      end
    end
  end

  def default_path() do
    home = System.get_env("HOME")
    Path.join(home, ".act")
  end

  def parse_default() do
    p = default_path()
    
    unless File.exists? p do
      File.touch!(p)
    end
    
    parse_file(p)
  end

end
