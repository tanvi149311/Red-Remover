--[[

 In this level light red squares and placed on top of a static platform and added as dynamic objects to the physics engine. There are also
 two half colored light red squares to the left an right of the platform. The squares are loaded as sprites and a timer is set on each of
 the squares to test if they have started to move and when they have stopped moving. This allows for setting the sprite with the correct face
 when the squares have started to move. When a square falls through the bottom of the screen it is removed and its variable reference is set to NIL.
 The static objects, which are the platform, and two half colored boxes, are removed when they are tapped via a tap event listener added to them.
 The red squares with the faces also have tap event listeners to remove them when they are tapped by the game player. Another timer is set to run
 through all of the objects and if it find that they are all NIL then it means that all of the red objects are gone and the level is completed,  
 at which point the level completed function is called. The user can then tap of the "continue" image to go to the next level or tap on the
 level select image to go back to the main game menu. Really, there is no way to fail this level since all the objects are red.

--]]

local composer = require("composer");
composer.removeScene( "level1", true )
composer.removeHidden()
local physics = require("physics");
physics.start(); 
physics.setGravity(0, 18.8);
local scene = composer.newScene(); -- Make this new scene

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

-- References for the background, continue button, level select button, try again button, success or failure message
local backgroundImage; 
local continueImage = nil; 
local tryAgainImage = nil; 
local message = nil; 
local levelSelectImage = nil;
local bottomCenterPlatform = nil; 
local leftLightRedBox = nil; 
local rightLightRedBox = nil;
local lightRedSquares = nil;
local levelDoneTimer = nil; 
local motionTimer = nil;
lightRedSquares = {};
-- frames from the image sheet that will be used for the game objects
local shapeOpts = { frames = {
                               {x = 14,  y = 141, width = 51,  height = 51},  -- 1 -  light red square 
                               {x = 244, y = 141, width = 51,  height = 51},  -- 2 -  dark red square
                               {x = 333, y = 78,  width = 51,  height = 51},  -- 3 -  green square  
                               {x = 587, y = 11,  width = 51,  height = 51},  -- 4 -  blue square    
                               {x = 304, y = 141, width = 76,  height = 51},  -- 5 -  light red rectangle
                               {x = 14,  y = 76,  width = 76,  height = 51},  -- 6 -  green rectangle
                               {x = 14,  y = 11,  width = 201, height = 51},  -- 7 -  long blue rectangle
                               {x = 284, y = 36,  width = 151, height = 26},  -- 8 -  long blue rectangular platform
                               {x = 388, y = 167, width = 301, height = 26},  -- 9 -  long light red rectangular platform
                               {x = 97,  y = 102, width = 221, height = 26},  -- 10 - long green half-colored rectangular platform
                               {x = 393, y = 103, width = 101, height = 26},  -- 11 - short green half-colored rectangular platform
                               {x = 500, y = 78,  width = 51,  height = 51},  -- 12 - green half-colored square
                               {x = 73,  y = 166, width = 101, height = 26},  -- 13 - short light red half-colored rectangular platform
                               {x = 183, y = 141, width = 51,  height = 51},  -- 14 - light red half-colored square 
                               {x = 448, y = 36,  width = 126, height = 26},  -- 15 - short blue half-colored rectangular platform
                               {x = 654, y = 36,  width = 51,  height = 26},  -- 16 - very short blue half-colored rectangular platform
                               {x = 239, y = 36,  width = 26,  height = 26},  -- 17 - small blue half-colored square
                               {x = 16,  y = 207, width = 23,  height = 15},  -- 18 - dark red frown
                               {x = 47,  y = 207, width = 23,  height = 15},  -- 19 - dark red grin
                               {x = 79,  y = 207, width = 23,  height = 15},  -- 20 - dark red smile
                               {x = 109, y = 207, width = 23,  height = 15},  -- 21 - dark red "Uh-Oh" face
                               {x = 144, y = 207, width = 23,  height = 15},  -- 22 - light red frown
                               {x = 176, y = 207, width = 23,  height = 15},  -- 23 - light red grin
                               {x = 207, y = 207, width = 23,  height = 15},  -- 24 - light red smile
                               {x = 237, y = 207, width = 23,  height = 15},  -- 25 - light red "Uh-Oh" face
                               {x = 272, y = 207, width = 23,  height = 15},  -- 26 - green frown
                               {x = 303, y = 207, width = 23,  height = 15},  -- 27 - green grin
                               {x = 335, y = 207, width = 23,  height = 15},  -- 28 - green smile
                               {x = 365, y = 207, width = 23,  height = 15},  -- 29 - green "Uh-Oh" face
                               {x = 397, y = 207, width = 23,  height = 15},  -- 30 - blue frown
                               {x = 428, y = 207, width = 23,  height = 15},  -- 31 - blue grin
                               {x = 460, y = 207, width = 23,  height = 15},  -- 32 - blue smile
                               {x = 490, y = 207, width = 23,  height = 15},  -- 33 - blue "Uh-Oh" face
                               {x = 14,  y = 234, width = 201, height = 51},  -- 34 - long blue rectangle with grin
                               {x = 14,  y = 234, width = 201, height = 51},  -- 35 - long blue rectangle with frown
                               {x = 221, y = 234, width = 201, height = 51},  -- 36 - long blue rectangle with grin
                               {x = 228, y = 234, width = 201, height = 51},  -- 37 - long blue rectangle with smile
                               {x = 636, y = 234, width = 201, height = 51},  -- 38 - long blue rectangle with "uh-oh" face
                               {x = 14,  y = 292, width = 151, height = 26},  -- 39 - long blue rectanglular platform with frown
                               {x = 171, y = 292, width = 151, height = 26},  -- 40 - long blue rectanglular platform with grin
                               {x = 326, y = 292, width = 151, height = 26},  -- 41 - long blue rectanglular platform with smile
                               {x = 483, y = 292, width = 151, height = 26},  -- 42 - long blue rectanglular platform with "uh-oh" face
                               {x = 14,  y = 327, width =  51, height = 51},  -- 43 - blue square with frown
                               {x = 69,  y = 327, width =  51, height = 51},  -- 44 - blue square with grin
                               {x = 123, y = 327, width =  51, height = 51},  -- 45 - blue square with smile
                               {x = 178, y = 327, width =  51, height = 51},  -- 46 - blue square with "uh-oh" face
                               {x = 232, y = 327, width =  51, height = 51},  -- 47 - green square with frown
                               {x = 286, y = 327, width =  51, height = 51},  -- 48 - green square with grin
                               {x = 341, y = 327, width =  51, height = 51},  -- 49 - green square with smile
                               {x = 396, y = 327, width =  51, height = 51},  -- 50 - green square with "uh-oh" face
                               {x = 450, y = 326, width =  50, height = 50},  -- 51 - light red square with frown
                               {x = 505, y = 326, width =  50, height = 50},  -- 52 - light red square with grin
                               {x = 560, y = 326, width =  50, height = 50},  -- 53 - light red square with smile
                               {x = 613, y = 326, width =  51, height = 50},  -- 54 - light red square with "uh-oh" face
                               {x = 668, y = 327, width =  51, height = 51},  -- 55 - dark red square with frown
                               {x = 723, y = 327, width =  51, height = 51},  -- 56 - dark red square with grin
                               {x = 776, y = 327, width =  51, height = 51},  -- 57 - dark red square with smile
                               {x = 829, y = 327, width =  51, height = 51},  -- 58 - dark red square with "uh-oh" face
                               {x = 14,  y = 386, width = 301, height = 26},  -- 59 - long light red rectangular platform with frown
                               {x = 320, y = 386, width = 301, height = 26},  -- 60 - long light red rectangular platform with grin
                               {x = 14,  y = 415, width = 301, height = 26},  -- 61 - long light red rectangular platform with smile
                               {x = 320, y = 415, width = 301, height = 26},  -- 62 - long light red rectangular platform with "uh-oh" face
                               {x = 14,  y = 445, width = 76,  height = 51},  -- 63 - green rectangle with frown
                               {x = 93,  y = 445, width = 76,  height = 51},  -- 64 - green rectangle with grin
                               {x = 173, y = 445, width = 76,  height = 51},  -- 65 - green rectangle with smile
                               {x = 253, y = 445, width = 76,  height = 51},  -- 66 - green rectangle with "uh-oh" face
                               {x = 412, y = 445, width = 76,  height = 51},  -- 67 - light red rectangle with frown
                               {x = 492, y = 445, width = 76,  height = 51},  -- 68 - light red rectangle with grin
                               {x = 572, y = 445, width = 76,  height = 51},  -- 69 - light red rectangle with smile
                               {x = 652, y = 445, width = 76,  height = 51},  -- 70 - light red rectangle with "uh-oh" face
                               {x = 710, y = 36,  width = 51,  height = 26},  -- 71 - very short light red half-colored rectangular platform
                               {x = 764, y = 36,  width = 24,  height = 26},  -- 72 - very small blue square with grin
                               {x = 790, y = 36,  width = 24,  height = 26},  -- 73 - very small blue square with smile
                               {x = 790, y = 36,  width = 24,  height = 26},  -- 74 - very small blue square with "Uh-Oh" face
                               {x = 388, y = 139, width = 476, height = 26},  -- 75 - very long blue half-colored rectangular platform
                             }
                  };

local imageSheet = graphics.newImageSheet("sheet1.png", shapeOpts); -- load the image sheet

-- Set up sequences for the sprites that will be used which are the red squares with faces
local shapeSeqData = {
                      {name = "frown", frames = {51} },
                      {name = "grin",  frames = {52} },
                      {name = "smile", frames = {53} },
                      {name = "uhoh",  frames = {54} },
                     };


-- Go to whatever scene is next, depending on whether level select, continue, or try again was tapped
local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level1", false )
end

-- This function is called if it is determined that the level has been completed successfully
        local function levelCompleted()

            sceneTransitionOptions.params.levelStatus[1] = "completed"; 
            sceneTransitionOptions.effect = "fromRight";
            message.text = "Success!"
            continueImage.isVisible=true ;
            continueImage:addEventListener("tap", nextLevel);

        end
        -----------============== LevelFailed function ===========
        ---===========================================================
        local function levelFailed()

            sceneTransitionOptions.params.levelStatus[1] = "attempted"; 
            sceneTransitionOptions.effect = "flip"; 
            sceneTransitionOptions.time = 0;
            message.text = "Failed!"
            tryAgainImage.isVisible=true ;
            tryAgainImage:addEventListener("tap", nextLevel);

        end


-- This function is called is the level select image at the bottom left of the screen is tapped allowing the player to go back to the main menu
local function levelSelect()

 -- cancel level done timer is it is still alive
 if levelDoneTimer ~= nil then

  timer.cancel(levelDoneTimer); levelDoneTimer = nil;

 end


  sceneTransitionOptions.effect = "fade"; sceneTransitionOptions.time = 400;
    composer.removeScene( "levelscreen", false )
    composer.gotoScene("levelscreen", sceneTransitionOptions);
    composer.removeScene( "level1", false )
end

-- This function is called every few milliseconds to see if the level is over with and failed or completed
local function levelDone()

 local done = true;


 -- if any red objects remain then the level is not over with ----------------------------------------------------------------------------
 
 if centerPlatform ~= nil or leftLightRedBox ~= nil or rightLightRedBox ~= nil then

  done = false;

 end

 for i = 1, 6 do

  if lightRedSquares[i] ~= nil then

   done = false;
   
  end

 end
 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------


 
 -- If there are no red objects remaining then the level has been successfully completed so call the levelCompleted function and cancel level done timer ----

 if done == true then

  timer.cancel(levelDoneTimer); levelDoneTimer = nil;

  levelCompleted();

 end 

 --------------------------------------------------------------------------------------------------------------------------------------------

end

--- This function is called every millisecond to test if any of the objects with faces are moving and change their facial expressions accordingly
local function getMotion()

  local vx, vy, magnitude;
  local squaresRemain = false;
 --- Cycle through all the red sqaures with faces and test their motion
  for i = 1, 6 do
      if lightRedSquares[i] ~= nil then
          if(lightRedSquares[i].getLinearVelocity ~= nil) then
              vx, vy = lightRedSquares[i]:getLinearVelocity(); 
              vx = math.abs(vx); vy = math.abs(vy);
              magnitude = math.sqrt(vx ^ 2 + vy ^ 2);   
            
            -- If starting to move or coming to a hault change their expressions ----------------------------------------------------------------------------------
              if magnitude == 0 and lightRedSquares[i].sequence ~= "frown" then 
                  lightRedSquares[i]:setSequence("frown"); lightRedSquares[i]:play();
              elseif magnitude > 1 and magnitude < 50 and lightRedSquares[i].sequence ~= "uhoh" then
                  lightRedSquares[i]:setSequence("uhoh"); lightRedSquares[i]:play();
              elseif magnitude > 50 and lightRedSquares[i].sequence ~= "smile" then 
                  lightRedSquares[i]:setSequence("smile"); lightRedSquares[i]:play();
              end
            
            --- If the one of the red squares have fallen off the screen remove the display object to free memory
              if lightRedSquares[i].y > (display.contentHeight + (shapeOpts.frames[1].height * 2.5) / 2) then
                  lightRedSquares[i]:removeSelf(); lightRedSquares[i] = nil;
              end
          end  
      end
  end

 --- Loop through all the red squares with faces and see if any remain
  for i = 1, 6 do
      if lightRedSquares[i] ~= nil then
          squaresRemain = true;
      end
  end
 
 --- If not then all objects that are movable are gone so cancel the timer meant the detect their motion
  if squaresRemain == false then
      timer.cancel(motionTimer); 
      motionTimer = nil;
  end
end

--- This function is called to remove an object that can be removed by tapping on it is tapped 
local function removeObject(event)

    if event.target.nameTag == "centerPlatform" and bottomCenterPlatform ~= nil then
        bottomCenterPlatform:removeSelf();
        bottomCenterPlatform = nil;
    end 

    if event.target.nameTag == "leftBox"  and leftLightRedBox ~= nil then
        leftLightRedBox:removeSelf();
        leftLightRedBox = nil;
    end

    if event.target.nameTag == "rightBox"  and rightLightRedBox ~= nil then
      rightLightRedBox:removeSelf();
      rightLightRedBox = nil;
    end

    if event.target.nameTag == "square" and lightRedSquares[event.target.index] ~= nil then
        lightRedSquares[event.target.index]:removeSelf(); 
        lightRedSquares[event.target.index] = nil;
    end

end

-- This function is called in the scene show function to put all of the objects on the screen and add them to the physics engine


---- Put some display objects in the group scene
function scene:create(event)
 
    local sceneGroup = self.view;

     -- Load and display the game background image
    backgroundImage = display.newImage("bg.png", display.contentCenterX, display.contentCenterY);
    backgroundImage:scale(display.contentWidth / backgroundImage.contentWidth, display.contentHeight / backgroundImage.contentHeight);
    sceneGroup:insert(backgroundImage); -- Insert background image into the scene group  

     -- Create image to tap on to go back to the main menu
    levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
    levelSelectImage:scale(1.6, 1.6);
    levelSelectImage:addEventListener("tap", levelSelect); -- Add tap event listener for return to menu screen
    sceneGroup:insert(levelSelectImage)
end


function scene:show(event)
 
  local sceneGroup = self.view;
  local phase = event.phase;
  local previousScene;

  if phase == "will" then 

    -- Loop through the parameters passed to this scene and put them in the parameters that will be passed to the next scene
    for i = 1, 9 do
        sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
    end

    local x, y, newWidth, newHeight; 
    local objectShape;

    ----- The bottom center light red platform ---------------------------------------------------------------------------- 
    bottomCenterPlatform = display.newImage(imageSheet, 13, display.contentCenterX, display.contentHeight - 200); 
    bottomCenterPlatform:scale(2.8, 2.5);
    bottomCenterPlatform.nameTag = "centerPlatform"
    sceneGroup:insert(bottomCenterPlatform)
    -------------------------------------------------------------------------------------------------------------------------
     --- The left and right half colored light red squares ------------------------------------------------------------------
    leftLightRedBox = display.newImage(imageSheet, 14, 10, display.contentHeight - 750);
    leftLightRedBox.anchorX = 0; 
    leftLightRedBox.anchorY = 0;
    leftLightRedBox:scale(2.5, 2.5);
    leftLightRedBox.nameTag = "leftBox";
    sceneGroup:insert(leftLightRedBox)

    rightLightRedBox = display.newImage(imageSheet, 14, display.contentWidth - 140, display.contentHeight - 750);
    rightLightRedBox.anchorX = 0; 
    rightLightRedBox.anchorY = 0;
    rightLightRedBox:scale(2.5, 2.5);
    rightLightRedBox.nameTag = "rightBox";
    sceneGroup:insert(rightLightRedBox)
     --------------------------------------------------------------------------------------------------------------------------
    -- Add the bottom center platform to the physics engine as a static object -----------------------------------------------
    newWidth = (shapeOpts.frames[13].width * 2.8) / 2; 
    newHeight = (shapeOpts.frames[13].height * 2.5) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody( bottomCenterPlatform, "static", { friction = 0.5, bounce = 0.3, shape = objectShape } );
    bottomCenterPlatform.gravityScale = 0;
 ---------------------------------------------------------------------------------------------------------------------------
 
 --- Add the left and right half colored red squares to the physics engine as static objects --------------------------------
    physics.addBody( leftLightRedBox, "static");
    leftLightRedBox.gravityScale = 0;

    physics.addBody( rightLightRedBox, "static");
    rightLightRedBox.gravityScale = 0;
 -----------------------------------------------------------------------------------------------------------------------------

 --- Create space for the red square sprites with faces and put them on top of the platform as dynamic objects ---------------
    

    x = bottomCenterPlatform.x - newWidth + 10; 
    y = bottomCenterPlatform.y - newHeight - ( (shapeOpts.frames[51].height * 2.5) / 2);

    for i = 1, 3 do
      lightRedSquares[i] = display.newSprite(imageSheet, shapeSeqData);
      lightRedSquares[i]:setSequence("frown"); 
      --lightRedSquares[i]:play();
      lightRedSquares[i]:scale(2.5, 2.5);
      lightRedSquares[i].x = x; 
      lightRedSquares[i].y = y;
      lightRedSquares[i]:toFront();
      lightRedSquares[i].nameTag = "square"; 
      lightRedSquares[i].index = i;
      x = x + (shapeOpts.frames[1].width * 2.5) + 3;
      sceneGroup:insert(lightRedSquares[i])
    end

    x = lightRedSquares[1].x + (shapeOpts.frames[51].width   * 2.5) / 2; 
    y = lightRedSquares[1].y - (shapeOpts.frames[51].height  * 2.5); 

    for i = 4, 5 do
      lightRedSquares[i] = display.newSprite(imageSheet, shapeSeqData);
      lightRedSquares[i]:setSequence("frown"); 
      --lightRedSquares[i]:play();
      lightRedSquares[i]:scale(2.5, 2.5);
      lightRedSquares[i].x = x; 
      lightRedSquares[i].y = y;
      lightRedSquares[i].nameTag = "square"; 
      lightRedSquares[i].index = i;
      x = x + (shapeOpts.frames[1].width * 2.5) + 3;  
      sceneGroup:insert(lightRedSquares[i])
    end

    lightRedSquares[6] = display.newSprite(imageSheet, shapeSeqData);
    lightRedSquares[6]:setSequence("frown"); 
    lightRedSquares[6]:play();
    lightRedSquares[6]:scale(2.5, 2.5);
    lightRedSquares[6].x = lightRedSquares[4].x + ((shapeOpts.frames[51].width  * 2.5) / 2);
    lightRedSquares[6].y = lightRedSquares[4].y -  (shapeOpts.frames[51].height * 2.5);
    lightRedSquares[6].nameTag = "square"; 
    lightRedSquares[6].index = 6; 
    sceneGroup:insert(lightRedSquares[6])

    newWidth = (shapeOpts.frames[51].width * 2.5) / 2; 
    newHeight = (shapeOpts.frames[51].height * 2.5) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};

    for i = 1, 6 do
      physics.addBody(lightRedSquares[i], "dynamic", {friction = 0.5, bounce = 0.3, shape = objectShape});
      lightRedSquares[i]:addEventListener("tap", removeObject); -- Set tap event listener so player can remove the square sprite by tapping on it
    end
     ----------------------------------------------------------------------------------------------------------------------------------------------

     --- Add tap event listeners to the paltform and the right and left boxes to allow for the user to remove them
    leftLightRedBox:addEventListener("tap", removeObject); 
    rightLightRedBox:addEventListener("tap", removeObject);
    bottomCenterPlatform:addEventListener("tap", removeObject);

    -- Start the physics engine and set gravity to 18.8 m/s2 downward

    -- Call function to create and place level objects

        message = display.newText("", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
        message:setFillColor(0, 0, 0);
        sceneGroup:insert( message);

        tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
        tryAgainImage.level = "dummy";
        tryAgainImage:scale(1.5, 1.5);
        tryAgainImage.isVisible=false;
        sceneGroup:insert( tryAgainImage);

        continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
        continueImage.level = "level2";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);

  elseif phase == "did" then
   
    motionTimer    = timer.performWithDelay(1, getMotion, -1); -- Start timer to detect motion of red squares sprites with faces
    levelDoneTimer = timer.performWithDelay(200, levelDone, -1); -- Start timer to continuously check if the level is done with

  end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then
   ----------------------------------------------------------------------------------------------------------------------------------------------------------

   elseif  phase == "did" then

   ---- If any timers are still alive then cancel them --------------------------------------------------------------------------------------------------------
    if motionTimer ~= nil then

     timer.cancel(motionTimer); motionTimer = nil;

    end
   
    if levelDoneTimer ~= nil then

     timer.cancel(levelDoneTimer); levelDoneTimer = nil;

    end
   
   end
  -------------------------------------------------------------------------------------------------------------------------------------------------------------
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