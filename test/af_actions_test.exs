defmodule AF.ActionsTest do
  use ExUnit.Case
  
  @base_folder "ActionFoldersTestDir"
  @sample_script_unix Path.expand("#{@base_folder}/sample script.exs")
  @sample_script_relative_unix "#{@base_folder}/sample script.exs"
  @sample_script_win Path.expand("#{@base_folder}/sample script.bat")
  @sample_script_relative_win "#{@base_folder}/sample script.bat"
  @sample_file "#{@base_folder}/sample.file"
  @sample_newfile_in_actionfolder "#{@base_folder}/testfolder.act/add_test.file"
  
  #test "can call an action" do
  #  # call action on file
  #  # check if file was changed appropriately
  #  script =
  #  case :os.type do
  #    {:win32, _} -> @sample_script_win
  #    {:unix, _} -> @sample_script_unix
  #  end
  #  
  #  assert {:ok, _} = AF.Actions.act_on_file(script, @sample_file)
  #end
  #
  #test "can call an action on relatively path'd script" do
  #  # call action on file
  #  # check if file was changed appropriately
  #  script =
  #  case :os.type do
  #    {:win32, _} -> @sample_script_relative_win
  #    {:unix, _} -> @sample_script_relative_unix
  #  end
  #  
  #  assert {:ok, _} = AF.Actions.act_on_file(script, @sample_file)
  #end
  
  test "can call an action just by the name of the file" do
    assert {:ok, _} = AF.Actions.act(@sample_newfile_in_actionfolder, "echo")
  end
  
  # test "cannot call an action on a non-executable" do
  #   assert {:error, _} = Actions.act_on_file(Path.expand("./ActionFoldersTestDir/sample script non-exec.exs"), [Path.expand("./ActionFoldersTestDir/sample.file")])
  # end
  
end
