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
    # assert Enum.any?(action_folders, &(&1 == Path.expand("./ActionFoldersTestDir/testfolder.act/subfolder-no-act/subsubfolder-with-act")))
    assert Path.expand("./ActionFoldersTestDir/testfolder.act/subfolder-no-act/subsubfolder-with-act") in action_folders
  end
  
end
