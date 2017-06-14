----Tanvi Pawale

local composer = require("composer");
composer.removeScene( "levelscreen", true )
local scene = composer.newScene(); -- Make this new scene

local sceneTransitionOptions = {
                                effect = "fade", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

local backgroundImage;

local shapeOpts = { frames = {
                               {x = 14,  y = 141, width = 51, height = 51}, -- light red square
                               {x = 333, y = 78,  width = 51, height = 51}, -- green square  
                               {x = 587, y = 11,  width = 51, height = 51},  -- blue square    
                             }
                  };

local imageSheet = graphics.newImageSheet("sheetrks.png", shapeOpts);

local levelSquares = nil; local levelNumbers = nil;


-- Go to levels screen when "play" is tapped
local function tapped(event)
 
  composer.removeScene( event.target.level, false );
  composer.gotoScene(event.target.level, sceneTransitionOptions);
  composer.removeScene( "levelscreen", false );

end


---- Put some display objects in the group scene
function scene:create(event)
 
 local sceneGroup = self.view;

 -- Load and display the Red Remover title image
 backgroundImage = display.newImage("bg.png", display.contentCenterX, display.contentCenterY);

 backgroundImage:scale(display.contentWidth / backgroundImage.contentWidth, display.contentHeight / backgroundImage.contentHeight);

 sceneGroup:insert(backgroundImage); -- Insert title screen image into the scene group

end

-- Nothing to do in this function
function scene:show(event)
 
   local sceneGroup = self.view;
   local phase = event.phase;
   local scene; local levelIndex = 1; local x, y;

   if phase == "will" then

    for i = 1, 9 do

     sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];

    end

    scene = composer.getSceneName("previous"); -- grab a reference to the previous scene

    if scene == "titlescreen" then -- if the previous scene was the opening title splash screen remove it to free memory
        
     composer.removeScene(scene);

    end

    if levelSquares == nil then

     levelSquares = {};
     
    end
    
    if levelNumbers == nil then

     levelNumbers = {};

    end

    levelIndex = 1;
      
    x = 148; y = 450;

    for i = 1, 3 do
     for j = 1, 3 do
      
      if (sceneTransitionOptions.params.levelStatus[levelIndex] == "notAttempted") then
         levelSquares[levelIndex] = display.newImage(imageSheet, 1, x, y);
         levelSquares[levelIndex].level = "level" .. levelIndex;
         levelSquares[levelIndex]:scale(2.5, 2.5); 
         levelSquares[levelIndex]:toFront();

         levelNumbers[levelIndex] = display.newText(levelIndex, x, y, system.nativeFont, 42);
         levelNumbers[levelIndex]:setFillColor(1, 1, 1); levelNumbers[levelIndex]:toFront();
         levelNumbers[levelIndex].level = "level" .. levelIndex;
         
         sceneGroup:insert(levelSquares[levelIndex]);
         sceneGroup:insert(levelNumbers[levelIndex]);
      
      elseif (sceneTransitionOptions.params.levelStatus[levelIndex] == "attempted") then
        levelSquares[levelIndex] = display.newImage(imageSheet, 2, x, y);
        levelSquares[levelIndex].level = "level" .. levelIndex;
        levelNumbers[levelIndex] = display.newText(levelIndex, x, y, system.nativeFont, 42);
        levelSquares[levelIndex]:scale(2.5, 2.5); levelSquares[levelIndex]:toFront();
        levelNumbers[levelIndex]:setFillColor(1, 1, 1); levelNumbers[levelIndex]:toFront();
        levelNumbers[levelIndex].level = "level" .. levelIndex;
        sceneGroup:insert(levelSquares[levelIndex]); 
        sceneGroup:insert(levelNumbers[levelIndex]);
      
      elseif (sceneTransitionOptions.params.levelStatus[levelIndex] == "completed") then
        levelSquares[levelIndex] = display.newImage(imageSheet, 3, x, y);
        levelSquares[levelIndex].level = "level" .. levelIndex;
        levelNumbers[levelIndex] = display.newText(levelIndex, x, y, system.nativeFont, 42);
        levelSquares[levelIndex]:scale(2.5, 2.5); levelSquares[levelIndex]:toFront();
        levelNumbers[levelIndex]:setFillColor(1, 1, 1); levelNumbers[levelIndex]:toFront();
        levelNumbers[levelIndex].level = "level" .. levelIndex;
        sceneGroup:insert(levelSquares[levelIndex]); 
        sceneGroup:insert(levelNumbers[levelIndex]);
      end
      
      x = x + 212; 
      levelIndex = levelIndex + 1;
     end 
     
     x = 148; y = y + 200;
    end   

   elseif phase == "did" then
    for i = 1, 9 do
     if levelSquares ~= nil then
      if levelSquares[i] ~= nil then
       levelSquares[i]:addEventListener("tap", tapped);
      end
     end
     --[[if levelNumbers ~= nil then
      if levelNumbers[i] ~= nil then
       levelNumbers[i]:addEventListener("tap", tapped);
      end
     end--]]
    end
   end
end
---- Remove the display objects if this scene is about to go away
function scene:hide(event)
   local sceneGroup = self.view
   local phase = event.phase

   if phase == "will" then

    --backgroundImage:removeSelf();

    if levelSquares ~= nil then
     for i = 1, 9 do
      if levelSquares[i] ~= nil then
       levelSquares[i]:removeSelf(); levelSquares[i] = nil;
      end
     end
    end
    levelSquares = nil;
    if levelNumbers ~= nil then
     for i = 1, 9 do
      if levelNumbers[i] ~= nil then
       levelNumbers[i]:removeSelf(); levelNumbers[i] = nil;
      end         
     end
    end
    levelNumbers = nil;
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