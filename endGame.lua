local composer = require("composer");
composer.removeScene( "endGame", true )
local scene = composer.newScene(); -- Make this new scene


local sceneTransitionOptions = {
                                effect = "fade", -- slide next level in from the right
                                time = 400, -- fade in a period of 400 milliseconds
                                params = {levelStatus} 
                               };
local wellDone;
local doneTime = nil;

     

-- Go to levels screen when "play" is tapped

---- Put some display objects in the group scene
function scene:create(event)
 
 local sceneGroup = self.view;

 wellDone = display.newImage("wellDone.png", display.contentCenterX, display.contentCenterY);

 --playImage:scale(1.5, 1.5);

 sceneGroup:insert(wellDone); -- Insert title screen image and play image into the scene group

end
 

-- Nothing to do in this function
function scene:show(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then

    -- sceneTransitionOptions.params.levelStatus = levelStatus;

    -- playImage:addEventListener("tap", tapped);

   elseif phase == "did" then
     
      local function newGame()

          options = {
            effect = "slideRight", 
            time = 500
          }

          composer.removeScene( "titlescreen", false )
          composer.gotoScene( "titlescreen", options)
          composer.removeScene( "endGame", false )
      end

      doneTime = timer.performWithDelay( 1000, newGame)
   end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then

    -- titleScreenImage:removeSelf();
    -- playImage:removeSelf();

    

   elseif  phase == "did" then
    if(doneTime ~= nil) then
      timer.cancel( doneTime )
      doneTime = nil
    end

   end

end
 
-- Composer destroy scene function
function scene:destroy(event)
 
   local sceneGroup = self.view
 
   -- Not really anything to do here either
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene                           