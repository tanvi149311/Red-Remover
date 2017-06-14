local composer = require("composer");
composer.removeScene( "titlescreen", true )
composer.removeHidden()
local scene = composer.newScene(); -- Make this new scene

local levelStatus = {"notAttempted", "notAttempted", "notAttempted", "notAttempted", "notAttempted", "notAttempted",  "notAttempted",  "notAttempted",  "notAttempted"};

local sceneTransitionOptions = {
                                effect = "fade", -- slide next level in from the right
                                time = 400, -- fade in a period of 400 milliseconds
                                params = {levelStatus} 
                               };

local titleScreenImage; local playImage;
     

-- Go to levels screen when "play" is tapped
local function tapped(event)
  composer.removeScene( "levelscreen", false )
  composer.gotoScene("levelscreen", sceneTransitionOptions);
  composer.removeScene( "titlescreen", false )
end

---- Put some display objects in the group scene
function scene:create(event)
 
 local sceneGroup = self.view;

 -- Load and display the Red Remover title image
 titleScreenImage = display.newImage("titlescreen.png", display.contentCenterX, display.contentCenterY);

 titleScreenImage:scale(display.contentWidth / titleScreenImage.contentWidth, display.contentHeight / titleScreenImage.contentHeight);
 sceneGroup:insert(titleScreenImage); 

 playImage = display.newImage("play.png", display.contentCenterX, display.contentCenterY + 460);

 playImage:scale(1.5, 1.5);

 sceneGroup:insert(playImage); -- Insert title screen image and play image into the scene group

end
 

-- Nothing to do in this function
function scene:show(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then

    sceneTransitionOptions.params.levelStatus = levelStatus;

    playImage:addEventListener("tap", tapped);

   elseif phase == "did" then
     
   end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then
    if(titleScreenImage ~= nil) then
      titleScreenImage:removeSelf();
    end
    if(playImage ~= nil) then
      playImage:removeSelf();
    end
   elseif  phase == "did" then
  
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