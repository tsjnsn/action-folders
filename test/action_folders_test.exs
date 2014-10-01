defmodule ActionFoldersTest do
  use ExUnit.Case
  
  setup do
    {:ok, actserv} = GenServer.start_link(ActionFolders, nil)
    {:ok, actserv: actserv}
  end
  
  test "can't create server with non-text argument", %{actserv: actserv} do
    assert {:error, _} = GenServer.call(actserv, {:set_root_action_folder, ["this", "is not valid!"]})
  end
  
  test "can't create server with non-existant argument", %{actserv: actserv} do
    assert {:error, _} = GenServer.call(actserv, {:set_root_action_folder, "./ActionFoldersTestDir/this/should/not/exist!"})
  end
  
  test "can't create server with file argument", %{actserv: actserv} do
    assert {:error, _} = GenServer.call(actserv, {:set_root_action_folder, "./ActionFoldersTestDir/sample.file"})
  end
  
  test "can create server with base folder", %{actserv: actserv} do
    assert {:ok, _} = GenServer.call(actserv, {:set_root_action_folder, "."})
  end
  
  test "can get the list of folders which have actions", %{actserv: actserv} do
    assert {:ok, _} = GenServer.call(actserv, {:set_root_action_folder, "./ActionFoldersTestDir"})
    
    action_folders = GenServer.call(actserv, :list_action_folders)
    assert is_list action_folders
    assert Path.expand("./ActionFoldersTestDir/testfolder.act/subfolder-no-act/subsubfolder-with-act") in action_folders
  end
  
  # test "file is detected when put in an Action Folder" do
  #   assert false
  # end
  
  # test "action is called on file when placed in an Action Folder" do
  #   assert false  
  # end
  
  test "can call an action" do
    # call action on file
    # check if file was changed appropriately
    assert {:ok, _} = Actions.act_on_file(Path.expand("./ActionFoldersTestDir/sample script.exs"), [Path.expand("./ActionFoldersTestDir/sample.file")])
  end
  
  test "cannot call an action on a non-executable" do
    assert {:error, _} = Actions.act_on_file(Path.expand("./ActionFoldersTestDir/sample script non-exec.exs"), [Path.expand("./ActionFoldersTestDir/sample.file")])
  end
  
end
