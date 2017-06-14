--- This is just a dummy scene to allow for reloaded "Try Again" scenes to restart with no hassles

local composer = require("composer");

local scene = composer.newScene();
 
local sceneTransitionOptions = {
                                effect = "flip", -- slide next level in from the right
                                time = 0, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

function scene:create(event) 
 
 local params = event.params
 

end
 
function scene:show(event)

 local phase = event.phase; 
 local scene; local previousScene;

 if phase == "will" then

  for i = 1, 9 do

    sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];

  end

 elseif phase == "did" then
 
  previousScene = composer.getSceneName("previous"); -- grab a reference to the previous scene

  composer.removeScene(previousScene);

  composer.gotoScene(previousScene, sceneTransitionOptions);  
 
 end

end
 
function scene:hide( event ) 

 local phase = event.phase 

 if phase == "will" then

 end

end
 
function scene:destroy( event )

end
 
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
return scene