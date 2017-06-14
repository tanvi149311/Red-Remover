--[[

  This level is a little to comlex to describe, but the usual way of handling my levels 1, 4, and 7 is employed. Objects and sprites
  are created, tap event listeners added to the appropriate objects to remove them, and timers started to detect object motions and check
  to see if the level is done with, and objects added to the physics engine to handle gravity and collisions.

--]]

local composer = require("composer");
composer.removeScene( "level7", true )
composer.removeHidden()

local scene = composer.newScene();

local physics = require( "physics") -- Make this new scene
physics.start(); 
physics.setGravity(0, 18.8);

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

-- References for the background, continue button, level select button, try again button, success or failure message
local backgroundImage; 
local continueImage = nil; 
local tryAgainImage = nil; 
local message = nil; local levelSelectImage = nil;

-- Frames of images in my image sheet
local shapeOpts = { frames = {
                               {x = 14,  y = 141, width = 51,  height = 51},  -- 1 -  light red square 
                               {x = 244, y = 141, width = 51,  height = 51},  -- 2 -  dark red square
                               {x = 333, y = 78,  width = 51,  height = 51},  -- 3 -  green square  
                               {x = 587, y = 11,  width = 51,  height = 51},  -- 4 -  blue square    
                               {x = 304, y = 141, width = 76,  height = 51},  -- 5 -  light red rectangle
                               {x = 14,  y = 76,  width = 76,  height = 51},  -- 6 -  green rectangle
                               {x = 14,  y = 11,  width = 201, height = 51},  -- 7 -  long blue rectangle
                               {x = 285, y = 36,  width = 150, height = 26},  -- 8 -  long blue rectangular platform
                               {x = 388, y = 167, width = 301, height = 26},  -- 9 -  long light red rectangular platform
                               {x = 97,  y = 102, width = 221, height = 26},  -- 10 - long green half-colored rectangular platform
                               {x = 393, y = 103, width = 101, height = 26},  -- 11 - short green half-colored rectangular platform
                               {x = 500, y = 78,  width = 51,  height = 51},  -- 12 - green half-colored square
                               {x = 73,  y = 166, width = 101, height = 26},  -- 13 - short light red half-colored rectangular platform
                               {x = 183, y = 141, width = 51,  height = 51},  -- 14 - light red half-colored square 
                               {x = 448, y = 36,  width = 126, height = 26},  -- 15 - short blue half-colored rectangular platform
                               {x = 654, y = 37,  width = 51,  height = 26},  -- 16 - very short blue half-colored rectangular platform
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
                               {x = 171, y = 291, width = 150, height = 25},  -- 40 - long blue rectanglular platform with grin
                               {x = 326, y = 292, width = 150, height = 25},  -- 41 - long blue rectanglular platform with smile
                               {x = 483, y = 292, width = 150, height = 25},  -- 42 - long blue rectanglular platform with "uh-oh" face
                               {x = 14,  y = 327, width =  51, height = 51},  -- 43 - blue square with frown
                               {x = 68,  y = 326, width =  50, height = 51},  -- 44 - blue square with grin
                               {x = 123, y = 326, width =  50, height = 51},  -- 45 - blue square with smile
                               {x = 178, y = 326, width =  51, height = 51},  -- 46 - blue square with "uh-oh" face
                               {x = 232, y = 327, width =  51, height = 51},  -- 47 - green square with frown
                               {x = 285, y = 326, width =  49, height = 50},  -- 48 - green square with grin
                               {x = 341, y = 326, width =  49, height = 50},  -- 49 - green square with smile
                               {x = 396, y = 326, width =  49, height = 50},  -- 50 - green square with "uh-oh" face
                               {x = 450, y = 326, width =  50, height = 50},  -- 51 - light red square with frown
                               {x = 505, y = 326, width =  50, height = 50},  -- 52 - light red square with grin
                               {x = 560, y = 326, width =  50, height = 50},  -- 53 - light red square with smile
                               {x = 613, y = 326, width =  51, height = 50},  -- 54 - light red square with "uh-oh" face
                               {x = 667, y = 327, width =  50, height = 50},  -- 55 - dark red square with frown
                               {x = 723, y = 327, width =  50, height = 50},  -- 56 - dark red square with grin
                               {x = 776, y = 327, width =  50, height = 50},  -- 57 - dark red square with smile
                               {x = 829, y = 327, width =  50, height = 50},  -- 58 - dark red square with "uh-oh" face
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
                               {x = 709, y = 36,  width = 52,  height = 26},  -- 71 - very short light red half-colored rectangular platform
                               {x = 764, y = 36,  width = 24,  height = 26},  -- 72 - very small blue square with grin
                               {x = 790, y = 36,  width = 24,  height = 26},  -- 73 - very small blue square with smile
                               {x = 816, y = 36,  width = 24,  height = 26},  -- 74 - very small blue square with "Uh-Oh" face
                               {x = 388, y = 138, width = 476, height = 26},  -- 75 - very long blue half-colored rectangular platform
                             }
                  };

local imageSheet = graphics.newImageSheet("sheet1.png", shapeOpts); -- Load my image sheet

-- Set up sequences for the sprites that will be used which are the level objects with faces
local shapeSeqData = {
                      {name = "blueRectGrin",   frames = {40} },
                      {name = "blueRectSmile",  frames = {41} },
                      {name = "blueRectUhOh",   frames = {42} },
                      {name = "darkRedFrown",   frames = {55} },
                      {name = "darkRedGrin",    frames = {56} },
                      {name = "darkRedSmile",   frames = {57} },
                      {name = "darkRedUhOh",    frames = {58} },
                      {name = "greenFrown",     frames = {47} },
                      {name = "greenGrin",      frames = {48} },
                      {name = "greenSmile",     frames = {49} },
                      {name = "greenUhOh",      frames = {50} },
                      {name = "blueGrin",       frames = {44} },
                      {name = "blueSmile",      frames = {45} },
                      {name = "blueUhOh",       frames = {56} },                      
                     };

--- Declare refernces for all of the objects used in this level and timers
local rectangularPlatforms = nil; 
local greenBoxes = nil; 
local redBoxes = nil; 
local blueHalfColoredBoxes = nil; 
local blueBox = nil; 
local gravityActive = false; 
local motionTimer = nil; 
local levelDoneTimer = nil;                    
greenBoxes = {};
blueHalfColoredBoxes = {};
rectangularPlatforms ={};

-- Go to whatever scene is next, depending on whether level select, continue, or try again was tapped
local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level7", false )
end

-- This function is called if it is determined that the level has been completed successfully
local function levelCompleted()
    if greenBoxes ~= nil then
      for i = 1, 5 do
          if greenBoxes[i] ~= nil and greenBoxes.setSequence ~= nil then
              greenBoxes[i]:setSequence("greenSmile"); 
          end
      end
    end

    if(message ~= nil) then
      
      sceneTransitionOptions.params.levelStatus[7] = "completed"; 
      sceneTransitionOptions.effect = "fromRight";
      message.text = "Success!"
      continueImage.isVisible=true ;
      continueImage:addEventListener("tap", nextLevel);
    end
end
        -----------============== LevelFailed function ===========
        ---===========================================================
local function levelFailed()

    sceneTransitionOptions.params.levelStatus[7] = "attempted"; 
    sceneTransitionOptions.effect = "flip"; 
    sceneTransitionOptions.time = 0;
    message.text = "Failed!"
    tryAgainImage.isVisible=true ;
    tryAgainImage:addEventListener("tap", nextLevel);

end

local function levelSelect()

 -- cancel level done timer is it is still alive
    if levelDoneTimer ~= nil then
        timer.cancel(levelDoneTimer); 
        levelDoneTimer = nil; 
    end

   if motionTimer ~= nil then
        timer.cancel(motionTimer); 
        motionTimer = nil; 
    end

    sceneTransitionOptions.effect = "fade"; 
    sceneTransitionOptions.time = 400;
    composer.removeScene( "levelscreen", false )
    composer.gotoScene("levelscreen", sceneTransitionOptions);
    composer.removeScene( "level7", false )
end

 -- Change the green boxes to show a smile upon level completion
 local function removeObject(event)
    local j = event.target.index
    if gravityActive == false then  
        for i = 1, 3 do
            rectangularPlatforms[i].gravityScale = 1;
        end
      
        for i = 1, 5 do
            greenBoxes[i].gravityScale = 1;
        end

        for i = 1, 2 do
          redBoxes[i].gravityScale = 1;
        end

        blueBox.gravityScale = 1;
        gravityActive = true;
    end

    if event.target.nameTag == "blueRect" and rectangularPlatforms[event.target.index] ~= nil then

        rectangularPlatforms[event.target.index]:removeEventListener("tap", removeObject)
        rectangularPlatforms[event.target.index].nameTag = nil;
        rectangularPlatforms[event.target.index]:removeSelf();
        rectangularPlatforms[event.target.index] = nil;
        
        
    end

    if event.target.nameTag == "blueBox" and blueBox ~= nil then
        event.target:removeEventListener("tap", removeObject)
        blueBox.nameTag = nil
        blueBox:removeSelf();
        
        blueBox = nil; 
    end 

    if event.target.nameTag == "blueHalfColored" and blueHalfColoredBoxes[event.target.index] ~= nil then
        event.target:removeEventListener("tap", removeObject)
        blueHalfColoredBoxes[event.target.index].nameTag = nil;
        blueHalfColoredBoxes[event.target.index]:removeSelf();
        blueHalfColoredBoxes[event.target.index] = nil;

    end
end


-- This function is called is the level select image at the bottom left of the screen is tapped allowing the player to go back to the main menu


-- This function is called every few milliseconds to see if the level is over with and failed or completed
local function levelDone()
  local redRemains = false; 
  local magnitude; 
  local greenStillMoving = false;
  local done = false
 -- if any the greenBox references are nil it means they fell off of the screen and the user failed the level
    for i = 1, 5 do
        if greenBoxes[i] == nil then 
            if levelDoneTimer ~= nil then
                timer.cancel(levelDoneTimer); 
                levelDoneTimer = nil;
            end 

            if motionTimer ~= nil then
                timer.cancel(motionTimer); 
                motionTimer = nil; 
            end        
            levelFailed();
        end
    end

 -- if any red objects remain then the level is not over with ----------------------------------------------------------------------------
    for i = 1, 2 do
        if redBoxes[i] ~= nil then
              redRemains = true;
        end   
    end
 ------------------------------------------------------------------------------------------------------------------------------------------------------
    for i = 1, 5 do
        if greenBoxes[i] ~= nil then
          if(greenBoxes.getLinearVelocity ~= nil) then
            vx, vy = greenBoxes[i]:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
    
            if magnitude > 12 then
                greenStillMoving = true;
            end
          end
        end
    end
 -- if no red objects remain and the green objects have stopped moving then level completed ---------------------------------------------------------------------
    if redRemains == false and greenStillMoving == false then        
        if levelDoneTimer ~= nil then
          timer.cancel(levelDoneTimer); 
          levelDoneTimer = nil;
        end

        if motionTimer ~= nil then
            timer.cancel(motionTimer); 
            motionTimer = nil; 
        end
        levelCompleted();
    end
 --------------------------------------------------------------------------------------------------------------------------------------------------------------- 
end

--- This function is called every millisecond to test if any of the objects with faces are moving and change their facial expressions accordingly
local function getMotion()

    local vx, vy, magnitude;
    local redBoxesRemain = false;

   --- Loop through the upright green rectangle sprites and test for motion to change their facial expressions as needed
    for i = 1, 5 do
      if greenBoxes[i] ~= nil then
          if(greenBoxes[i].getLinearVelocity ~= nil) then
          vx, vy = greenBoxes[i]:getLinearVelocity(); 
          vx = math.abs(vx); vy = math.abs(vy);
          magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
          
          if magnitude < 12 and greenBoxes[i].sequence ~= "greenGrin" then
              greenBoxes[i]:setSequence("greenGrin"); 
              --greenBoxes[i]:play();
          elseif magnitude > 12 and greenBoxes[i].sequence ~= "greenUhOh" then
              greenBoxes[i]:setSequence( "greenUhOh" ); 
              --greenBoxes[i]:play()
          end  

          if greenBoxes[i].y > display.contentHeight + shapeOpts.frames[48].height then
              greenBoxes[i].nameTag = nil
              greenBoxes[i]:removeSelf(); 
              greenBoxes[i] = nil;
          end
        end
      end


    end  

   --- Loop through the upright red rectangle sprites and test for motion to change their facial expressions as needed
    for i = 1, 2 do
        if redBoxes[i] ~= nil then
          if(redBoxes[i].getLinearVelocity ~= nil) then  
            vx, vy = redBoxes[i]:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
            if magnitude < 12 and redBoxes[i].sequence ~= "darkRedFrown" then
                redBoxes[i]:setSequence("darkRedFrown"); 
                --redBoxes[i]:play();
            elseif magnitude > 12 and magnitude < 50 and redBoxes[i].sequence ~= "darkRedUhOh" then
                redBoxes[i]:setSequence("darkRedUhOh"); 
                --redBoxes[i]:play()
            elseif magnitude > 50 and redBoxes[i].sequence ~= "darkRedSmile" then
                redBoxes[i]:setSequence("darkRedSmile"); 
                --redBoxes[i]:play();
            end  
        
            if redBoxes[i].y > display.contentHeight + shapeOpts.frames[55].height then
                redBoxes[i].nameTag = nil
                redBoxes[i]:removeSelf(); 
                redBoxes[i] = nil;
            end
          end
        end
    end

   --- Loop through the upright blue rectangle sprites and test for motion to change their facial expressions as needed
    for i = 1, 3 do
      if rectangularPlatforms[i] ~= nil then
        if(rectangularPlatforms[i].getLinearVelocity ~= nil) then
            vx, vy = rectangularPlatforms[i]:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
          
            if magnitude < 12 and rectangularPlatforms[i].sequence ~= "blueRectGrin" then
                rectangularPlatforms[i]:setSequence("blueRectGrin"); 
                --rectangularPlatforms[i]:play();
            elseif magnitude > 12 and magnitude < 50 and rectangularPlatforms[i].sequence ~= "blueRectUhOh" then
                rectangularPlatforms[i]:setSequence("blueRectUhOh"); 
                --rectangularPlatforms[i]:play()
            elseif magnitude > 50 and rectangularPlatforms[i].sequence ~= "blueRectSmile" then
                rectangularPlatforms[i]:setSequence("blueRectSmile"); 
                --rectangularPlatforms[i]:play();
            end  

            if rectangularPlatforms[i].y > display.contentHeight + shapeOpts.frames[40].width then
                rectangularPlatforms[i].nameTag = nil
                rectangularPlatforms[i]:removeSelf(); 
                rectangularPlatforms[i] = nil;
            end
        end
      end
    end

   --- Check if the blue box sprite for motion to change it's facial expression as needed
    if blueBox ~= nil then
      if(blueBox.getLinearVelocity ~= nil) then
        vx, vy = blueBox:getLinearVelocity(); 
        vx = math.abs(vx); vy = math.abs(vy);
        magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
        if magnitude < 12 and blueBox.sequence ~= "blueGrin" then
            blueBox:setSequence("blueGrin"); 
            --blueBox:play();
        elseif magnitude > 12 and magnitude < 50 and blueBox.sequence ~= "blueUhOh" then
            blueBox:setSequence("blueUhOh"); 
            --blueBox:play()
        elseif magnitude > 50 and blueBox.sequence ~= "blueSmile" then
            blueBox:setSequence("blueSmile"); 
            --blueBox:play(); 
        end  
        
        if blueBox.y > display.contentHeight + shapeOpts.frames[44].height then
            blueBox.nameTag = nil
            blueBox:removeSelf(); 
            blueBox = nil;
        end
      end
    end 

    for i = 1, 2 do
        if redBoxes[i] ~= nil then
            redBoxesRemain = true;

        end 
        --print( redBoxesRemain )
    end
      
    if redBoxesRemain == false then
        if motionTimer ~= nil then
            timer.cancel(motionTimer); 
            motionTimer = nil;
        end
    end

    if levelDoneTimer == nil then

     levelDoneTimer = timer.performWithDelay(1, levelDone, -1);

    end 
end

--- This function is called to remove an object that can be removed by tapping on it is tapped

-- This function is called in the scene show function to put all of the objects on the screen and add them to the physics engine


---- Put some display objects in the group scene
function scene:create(event)
 
    local sceneGroup = self.view;
 -- Load and display the game background image
    backgroundImage = display.newImage("bg.png", display.contentCenterX, display.contentCenterY);
    backgroundImage:scale(display.contentWidth / backgroundImage.contentWidth, display.contentHeight / backgroundImage.contentHeight);
    sceneGroup:insert(backgroundImage); -- Insert background image into the scene group  

end


function scene:show(event)
 
    local sceneGroup = self.view;
    local phase = event.phase;
    local previousScene;

    gravityActive = false; -- This variable is used to turn gravity off on objects until the first object is tapped to kick off game machanics

   -- Loop through the parameters passed to this scene and put them in the parameters that will be passed to the next scene
    if phase == "will" then 

        for i = 1, 9 do
          sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
        end

      local newWidth, newHeight; local objectShape;

 
 --- Blue Rectangular Platforms ---------------------------------------------------------------------------------------------------------------------------------
    for i = 1, 3 do
        if i == 1 then
           rectangularPlatforms[i] = display.newSprite(imageSheet, shapeSeqData);
           rectangularPlatforms[i]:setSequence("blueRectGrin"); 
           rectangularPlatforms[i]:play();
           rectangularPlatforms[i].x = (display.contentWidth / 4) - 40; 
           rectangularPlatforms[i].y = display.contentCenterY - 100;
           rectangularPlatforms[i]:rotate(1);
           rectangularPlatforms[i]:scale(1.8, 2);
           newWidth = (shapeOpts.frames[40].width * 1.8) / 2; 
           newHeight = shapeOpts.frames[40].height;
           objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
           physics.addBody(rectangularPlatforms[i], "dynamic", {friction = 25, bounce = 0.05, shape = objectShape});
           rectangularPlatforms[i].isSleepingAllowed = false;
           rectangularPlatforms[i].gravityScale = 0;
           rectangularPlatforms[i].nameTag = "blueRect"; 
           rectangularPlatforms[i].index = i;
           sceneGroup:insert( rectangularPlatforms[i] )
            if(rectangularPlatforms[i] ~= nil) then
                rectangularPlatforms[i]:addEventListener("tap", removeObject);
            end
        elseif i == 2 then
            rectangularPlatforms[i] = display.newSprite(imageSheet, shapeSeqData);
            rectangularPlatforms[i]:setSequence( "blueRectGrin"); 
            rectangularPlatforms[i]:play();
            rectangularPlatforms[i].x = (display.contentCenterX - 50) + 10; 
            rectangularPlatforms[i].y = display.contentCenterY + 35;
            rectangularPlatforms[i]:rotate(1);
            rectangularPlatforms[i]:scale(3, 2);
            newWidth = (shapeOpts.frames[40].width * 3) / 2; 
            newHeight = shapeOpts.frames[40].height;
            objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
            physics.addBody(rectangularPlatforms[i], "dynamic", {friction = 5, bounce = 0.1, shape = objectShape});
            rectangularPlatforms[i].isSleepingAllowed = false;
            rectangularPlatforms[i].gravityScale = 0;
            rectangularPlatforms[i].nameTag = "blueRect"; 
            rectangularPlatforms[i].index = i;
            sceneGroup:insert( rectangularPlatforms[i] )
            if(rectangularPlatforms[i] ~= nil) then
            rectangularPlatforms[i]:addEventListener("tap", removeObject);
            end
        elseif i == 3 then
            rectangularPlatforms[i] = display.newSprite(imageSheet, shapeSeqData);
            rectangularPlatforms[i]:setSequence( "blueRectGrin"); 
            rectangularPlatforms[i]:play();
            rectangularPlatforms[i].x = (display.contentCenterX + 150) + 25; 
            rectangularPlatforms[i].y =  display.contentCenterY + 172;
            rectangularPlatforms[i]:rotate(-0.25);
            rectangularPlatforms[i]:scale(2.4, 2);
            newWidth = (shapeOpts.frames[40].width * 2.4) / 2; 
            newHeight = shapeOpts.frames[40].height;
            objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
            physics.addBody(rectangularPlatforms[i], "dynamic", {friction = 5, bounce = 0.1, shape = objectShape});
            rectangularPlatforms[i].isSleepingAllowed = false;
            rectangularPlatforms[i].gravityScale = 0;
            rectangularPlatforms[i].nameTag = "blueRect"; 
            rectangularPlatforms[i].index = i;
            sceneGroup:insert( rectangularPlatforms[i] )
            if(rectangularPlatforms[i] ~= nil) then
            rectangularPlatforms[i]:addEventListener("tap", removeObject);
            end
        end
    end 
 --- Green Boxes--------------------------------------------------------------------------------------------------------------------------------------------------

    x = rectangularPlatforms[1].x - (shapeOpts.frames[40].width * 1.8) + ((shapeOpts.frames[40].width * 1.8) * (2/3)); 
    y = rectangularPlatforms[1].y - shapeOpts.frames[40].height - (shapeOpts.frames[48].height * 1.7) / 2;
    newWidth = (shapeOpts.frames[48].width * 1.85) / 2; 
    newHeight = (shapeOpts.frames[48].height * 1.7) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
      for i = 1, 3 do
          greenBoxes[i] = display.newSprite(imageSheet, shapeSeqData);
          greenBoxes[i]:setSequence("greenGrin"); greenBoxes[i]:play();
          greenBoxes[i]:scale(1.85, 1.7);
          greenBoxes[i].x = x; greenBoxes[i].y = y;
          physics.addBody(greenBoxes[i], "dynamic", {friction = 5, bounce = 0.02, shape = objectShape});
          greenBoxes[i].isSleepingAllowed = false;
          greenBoxes[i].gravityScale = 0;
          sceneGroup:insert( greenBoxes[i] )
          x = x + (shapeOpts.frames[48].width * 1.85); 
      end

    greenBoxes[4] = display.newSprite(imageSheet, shapeSeqData);
    greenBoxes[4]:setSequence("greenGrin"); greenBoxes[4]:play();
    greenBoxes[4]:scale(1.85, 1.7);
    greenBoxes[4].x = greenBoxes[2].x; 
    greenBoxes[4].y = rectangularPlatforms[2].y - shapeOpts.frames[40].height - ((shapeOpts.frames[48].height * 1.7) / 2);
    physics.addBody(greenBoxes[4], "dynamic", {friction = 25, bounce = 0.02, shape = objectShape});
    greenBoxes[4].isSleepingAllowed = false;
    greenBoxes[4].gravityScale = 0;
    sceneGroup:insert( greenBoxes[4] )

    x = rectangularPlatforms[2].x  + ((shapeOpts.frames[40].width * 3) / 5.5);   
    y = rectangularPlatforms[2].y - shapeOpts.frames[40].height - ((shapeOpts.frames[48].height * 1.7) / 2);
    greenBoxes[5] = display.newSprite(imageSheet, shapeSeqData);
    greenBoxes[5]:setSequence("greenGrin"); 
    greenBoxes[5]:play();
    greenBoxes[5]:scale(1.85, 1.7);
    greenBoxes[5].x = x - 2; 
    greenBoxes[5].y = y;
    physics.addBody(greenBoxes[5], "dynamic", {friction = 5, bounce = 0.1, shape = objectShape});
    greenBoxes[5].isSleepingAllowed = false;
    greenBoxes[5].gravityScale = 0;
    sceneGroup:insert( greenBoxes[5] )

 ---- Blue Box ---------------------------------------------------------------------------------------------------------------------------------------------------
    x = rectangularPlatforms[2].x + ((shapeOpts.frames[40].width * 3) / 2) - ((shapeOpts.frames[44].width * 1.4) / 2) - 5; 
    y = rectangularPlatforms[3].y - shapeOpts.frames[40].height - ((shapeOpts.frames[44].height * 1.7) / 2);
    blueBox = display.newSprite(imageSheet, shapeSeqData);
    blueBox:setSequence("blueGrin"); blueBox:play();
    blueBox.x = x - 5; 
    blueBox.y = y;
    blueBox:scale(1.4, 1.7);
    newWidth = (shapeOpts.frames[44].width * 1.4) / 2; 
    newHeight = (shapeOpts.frames[44].height * 1.7) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(blueBox, "dynamic", {friction = 5, bounce = 0.1, shape = objectShape});
    blueBox.isSleepingAllowed = false;
    blueBox.gravityScale = 0;
    blueBox.nameTag = "blueBox";
    sceneGroup:insert( blueBox )
    if(blueBox ~= nil) then
        blueBox:addEventListener("tap", removeObject);
    end
 ---- Red Boxes -------------------------------------------------------------------------------------------------------------------------------------------------

    x = rectangularPlatforms[1].x + ((shapeOpts.frames[40].width * 1.8) / 2) - 30;
    y = rectangularPlatforms[2].y - shapeOpts.frames[40].height - ((shapeOpts.frames[55].height * 1.7) / 2);

    redBoxes = {};
    redBoxes[1] = display.newSprite(imageSheet, shapeSeqData);
    redBoxes[1]:setSequence("darkRedFrown"); 
    redBoxes[1]:play();
    redBoxes[1].x = x; redBoxes[1].y = y;
    redBoxes[1]:scale(1.85, 1.7);
    newWidth = (shapeOpts.frames[55].width * 1.85) / 2; 
    newHeight = (shapeOpts.frames[55].height * 1.7) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(redBoxes[1], "dynamic", {friction = 5, bounce = 0.02, shape = objectShape});
    redBoxes[1].isSleepingAllowed = false;
    redBoxes[1].gravityScale = 0; 
    sceneGroup:insert( redBoxes[1] )

    x = blueBox.x + ((shapeOpts.frames[55].width * 1.85) / 2) + ((shapeOpts.frames[55].width * 1.4) / 4) + 40; 
    y = rectangularPlatforms[3].y - shapeOpts.frames[40].height - ((shapeOpts.frames[55].height * 1.7) / 2);
    redBoxes[2] = display.newSprite(imageSheet, shapeSeqData);
    redBoxes[2]:setSequence("darkRedFrown"); 
    redBoxes[2]:play();
    redBoxes[2].x = x - 5; redBoxes[2].y = y;
    redBoxes[2]:scale(1.4, 1.7);
    newWidth = (shapeOpts.frames[55].width * 1.4) / 2; 
    newHeight = (shapeOpts.frames[55].height * 1.7) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(redBoxes[2], "dynamic", {friction = 5, bounce = 0.1, shape = objectShape});
    redBoxes[2].isSleepingAllowed = false;
    redBoxes[2].gravityScale = 0;
    sceneGroup:insert( redBoxes[2] )

 --- Half Colored Blue Boxes ------------------------------------------------------------------------------------------------------------------------------------

    x = rectangularPlatforms[2].x - ((shapeOpts.frames[40].width * 3) / 2) + ((shapeOpts.frames[17].width * 3.6) / 2);
    y = rectangularPlatforms[2].y + shapeOpts.frames[40].height + ((shapeOpts.frames[17].height * 3) / 2);
    blueHalfColoredBoxes[1] = display.newImage(imageSheet, 17, x, y);
    blueHalfColoredBoxes[1]:scale(3.6, 3);
    newWidth = (shapeOpts.frames[17].width * 3.6) / 2; 
    newHeight = (shapeOpts.frames[17].height * 3) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(blueHalfColoredBoxes[1], "static", {friction = 5, bounce = 0.02, shape = objectShape});
    blueHalfColoredBoxes[1].nameTag = "blueHalfColored"; blueHalfColoredBoxes[1].index = 1;
    if(blueHalfColoredBoxes[1] ~= nil) then
    blueHalfColoredBoxes[1]:addEventListener("tap", removeObject);
    end
    blueHalfColoredBoxes[1].isSleepingAllowed = false;
    sceneGroup:insert( blueHalfColoredBoxes[1])

    x = rectangularPlatforms[3].x - ((shapeOpts.frames[40].width * 2.4) / 2) + ((shapeOpts.frames[17].width * 3.6) / 2);
    y = rectangularPlatforms[3].y + shapeOpts.frames[40].height + ((shapeOpts.frames[17].height * 3) / 2);
    blueHalfColoredBoxes[2] = display.newImage(imageSheet, 17, x, y);
    blueHalfColoredBoxes[2]:scale(3.6, 3);
    newWidth = (shapeOpts.frames[17].width * 3.6) / 2; newHeight = (shapeOpts.frames[17].height * 3) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(blueHalfColoredBoxes[2], "static", {friction = 5, bounce = 0.1, shape = objectShape});
    blueHalfColoredBoxes[2].nameTag = "blueHalfColored"; blueHalfColoredBoxes[2].index = 2;
    if(blueHalfColoredBoxes[2] ~= nil) then
    blueHalfColoredBoxes[2]:addEventListener("tap", removeObject);
    end
    blueHalfColoredBoxes[2].isSleepingAllowed = false;
    sceneGroup:insert( blueHalfColoredBoxes[2])

    x = rectangularPlatforms[3].x + ((shapeOpts.frames[40].width * 2.4) / 2) - ((shapeOpts.frames[17].width * 3.6) / 2);
    y = rectangularPlatforms[3].y + shapeOpts.frames[40].height + ((shapeOpts.frames[17].height * 3) / 2);
    blueHalfColoredBoxes[3] = display.newImage(imageSheet, 17, x, y);
    blueHalfColoredBoxes[3]:scale(3.6, 3);
    newWidth = (shapeOpts.frames[17].width * 3.6) / 2; 
    newHeight = (shapeOpts.frames[17].height * 3) / 2;
    objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
    physics.addBody(blueHalfColoredBoxes[3], "static", {friction = 5, bounce = 0.1, shape = objectShape});
    blueHalfColoredBoxes[3].nameTag = "blueHalfColored"; blueHalfColoredBoxes[3].index = 3;
    if(blueHalfColoredBoxes[3] ~= nil) then
    blueHalfColoredBoxes[3]:addEventListener("tap", removeObject);
    end
    blueHalfColoredBoxes[3].isSleepingAllowed = false;
    sceneGroup:insert( blueHalfColoredBoxes[3])

 ---- Half Colored Blue Boxes -----------------------------------------------------------------------------------------------------------------------------------


  elseif phase == "did" then
   
    -- Create image to tap on to go back to the main menu
        levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
        levelSelectImage:scale(1.6, 1.6);
        levelSelectImage:addEventListener("tap", levelSelect); 
        sceneGroup:insert( levelSelectImage )

        message = display.newText("", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
        message:setFillColor(0, 0, 0);
        sceneGroup:insert( message);

        tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
        tryAgainImage.level = "dummy";
        tryAgainImage:scale(1.5, 1.5);
        tryAgainImage.isVisible=false;
        sceneGroup:insert( tryAgainImage);

        continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
        continueImage.level = "level8";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);-- Add tap event listener for return to menu screen

        if motionTimer == nil then

         motionTimer = timer.performWithDelay(1, getMotion, -1); -- Start timer to detect motion of sprites with faces

        end 
    end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then
   --- Remove any display objects that may still be present when the scene is about to go away ----------------------------------------------------

    -- if continueImage ~= nil then

    --  continueImage:removeSelf();
    --  continueImage = nil;

    -- end

    -- if tryAgainImage ~= nil then

    --  tryAgainImage:removeSelf();
    --  tryAgainImage = nil;

    -- end
    
    -- if message ~= nil then

    --  message:removeSelf();
    --  message = nil;
 
    -- end

    -- if levelSelectImage ~= nil then

    --  levelSelectImage:removeSelf();
    --  levelSelectImage = nil;

    -- end
    
   --  if rectangularPlatforms ~= nil then

   --   for i = 1, 3 do

   --    if rectangularPlatforms[i] ~= nil then

   --     rectangularPlatforms[i]:removeSelf(); rectangularPlatforms[i] = nil;

   --    end
        
   --   end

   --  end

   --  if greenBoxes ~= nil then

   --   for i = 1, 5 do

   --    if greenBoxes[i] ~= nil then

   --      greenBoxes[i]:removeSelf(); greenBoxes[i] = nil;

   --    end

   --   end 

   --  end
    
   --  if redBoxes ~= nil then

   --   for i = 1, 2 do

   --    if redBoxes[i] ~= nil then

   --     redBoxes[i]:removeSelf(); redBoxes[i] = nil;

   --    end

   --   end 

   --  end

   --  if blueHalfColoredBoxes ~= nil then

   --   for i = 1, 3 do

   --    if blueHalfColoredBoxes[i] ~= nil then

   --     blueHalfColoredBoxes[i]:removeSelf(); blueHalfColoredBoxes[i] = nil;

   --    end  

   --   end
      
   --  end
    
   --  if blueBox ~= nil then

   --   blueBox:removeSelf(); blueBox = nil;

   --  end  
   -- ----------------------------------------------------------------------------------------------------------------------------------------------------------

   elseif phase == "did" then

   ---- If any timers are still alive then cancel them -----------------------------------------------------------------------------------------------------
    if levelDoneTimer ~= nil then

     timer.cancel(levelDoneTimer); levelDoneTimer = nil;

    end
    
    if motionTimer ~= nil then

     timer.cancel(motionTimer); motionTimer = nil;

    end
  
   end
   ----------------------------------------------------------------------------------------------------------------------------------------------------------
end
 
-- Composer destroy scene function
function scene:destroy(event)
 
   local sceneGroup = self.view
    if continueImage ~= nil then

     continueImage:removeSelf();
     continueImage = nil;

    end

    if tryAgainImage ~= nil then

     tryAgainImage:removeSelf();
     tryAgainImage = nil;

    end
    
    if message ~= nil then

     message:removeSelf();
     message = nil;
 
    end
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