--[[

 In this level 4 dark red boxes rest on small blue platforms that can be removed by clicking on then. There is a blue platform near
 the bottom of the screen where blue rectangle sprites with faces rest on end standing upright. One green box rests on a light red,
 and thus removable, platorm to the right of the screen. There are blue paltforms below the bottom center platform to the right which 
 can catch the green box sprite when it falls. There is also a very small blue sprite box object to the far left held back by a small 
 blue platform. If that small blue platform is removed by tapping on it the small blue sprite box will shoot across the screen causing 
 the upright blue rectangle sprite objects to fall like dominoes. Removable objects have a tap event listner attached to them as per 
 other levels and there are timers to test when objects with faces are moving to change their facial expressions accordingly, as well 
 as a timer that fires every couple of milliseconds to see if the level has been completed or failed.

--]]

local composer = require("composer");
composer.removeScene( "level4", true )
composer.removeHidden()
local scene = composer.newScene(); -- Make this new scene
local physics = require( "physics")
physics.start(); 
physics.setGravity(0, 18.8);

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

-- References for the background, continue button, level select button, try again button, success or failure message
local backgroundImage; local continueImage = nil; local tryAgainImage = nil; local message = nil; local levelSelectImage = nil;

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
                               {x = 69,  y = 327, width =  51, height = 51},  -- 44 - blue square with grin
                               {x = 123, y = 327, width =  51, height = 51},  -- 45 - blue square with smile
                               {x = 178, y = 327, width =  51, height = 51},  -- 46 - blue square with "uh-oh" face
                               {x = 232, y = 327, width =  51, height = 51},  -- 47 - green square with frown
                               {x = 285, y = 326, width =  49, height = 50},  -- 48 - green square with grin
                               {x = 342, y = 326, width =  49, height = 50},  -- 49 - green square with smile
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
                      {name = "smallBlueGrin",  frames = {72} },
                      {name = "smallBlueSmile", frames = {73} },
                      {name = "smallBlueUhOh",  frames = {74} },
                     };

--- Declare refernces for all of the objects used in this level and timers
local blueCenterPlatform = nil; 
local uprightBlueRectangles = nil; 
local shortBluePlatforms = nil; 
local redBoxes = nil; 
local lightRedPlatform = nil; 
local greenBox = nil; 
local smallBluePlatform = nil; 
local smallblueBox = nil; 
local smallBlueBoxTimer = nil; 
local redMotionTimer = nil; 
local greenMotionTimer = nil; 
local blueMotionTimer = nil; 
local levelDoneTimer = nil;
shortBluePlatforms = {}; 
redBoxes = {};
uprightBlueRectangles = {};


-- Go to whatever scene is next, depending on whether level select, continue, or try again was tapped
local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level4", false )
end

-- This function is called if it is determined that the level has been completed successfully
local function levelCompleted()
    if greenBox ~= nil then
        greenBox:setSequence("greenSmile"); 
        greenBox:play(); -- Change the green box to show a smile upon level completion
    end
    sceneTransitionOptions.params.levelStatus[4] = "completed"; 
    sceneTransitionOptions.effect = "fromRight";
    message.text = "Success!"
    continueImage.isVisible=true ;
    continueImage:addEventListener("tap", nextLevel);
end
        -----------============== LevelFailed function ===========
        ---===========================================================
local function levelFailed()

    sceneTransitionOptions.params.levelStatus[4] = "attempted"; 
    sceneTransitionOptions.effect = "flip"; 
    sceneTransitionOptions.time = 0;
    message.text = "Failed!"
    tryAgainImage.isVisible=true ;
    tryAgainImage:addEventListener("tap", nextLevel);
end
-- This function is called if it is determined that the level has been completed successfully


-- This function is called is the level select image at the bottom left of the screen is tapped allowing the player to go back to the main menu
local function levelSelect()

 -- cancel level done timer is it is still alive
 if levelDoneTimer ~= nil then

  timer.cancel(levelDoneTimer); levelDoneTimer = nil;

 end


    sceneTransitionOptions.effect = "fade"; sceneTransitionOptions.time = 400;
    composer.removeScene( "levelscreen", false )
    composer.gotoScene("levelscreen", sceneTransitionOptions);
    composer.removeScene( "level4", false )
end

-- This function is called every few milliseconds to see if the level is over with and failed or completed
local function levelDone()

    local redRemains = false; 
    local magnitude;

   -- if the greenBox reference is nil it means it fell off of the screen and the user failed the level
    if greenBox == nil then
        if levelDoneTimer ~= nil then
            timer.cancel(levelDoneTimer); 
            levelDoneTimer = nil; 
        end
        levelFailed();
    end
   
   -- if any red objects remain then the level is not over with ----------------------------------------------------------------------------
    for i = 1, 4 do
      if redBoxes[i] ~= nil then
          redRemains = true;
      end
    end

    if lightRedPlatform ~= nil then
        redRemains = true;
    end
 ------------------------------------------------------------------------------------------------------------------------------------------------------
 -- check to see if the green box is still alive after the red platform holding was removed -----------------------------------------------------------
    if greenBox ~= nil then

        if(greenBox.getLinearVelocity ~= nil) then
            vx, vy = greenBox:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);       
            if redRemains == false and magnitude == 0 and greenBox.y > display.contentCenterY then
                if levelDoneTimer ~= nil then
                    timer.cancel(levelDoneTimer); 
                    levelDoneTimer = nil;
                end
                levelCompleted();
            end
        end
     end
     ----------------------------------------------------------------------------------------------------------------------------------------------------------
end

--- This function is called every millisecond to test if any of the blue objects with faces are moving and change their facial expressions accordingly
local function getBlueMotion()

    local vx, vy, magnitude; 
  --- Loop through the upright blue rectagle sprites and test for motion to change their facial expressions as needed
    for i = 1, 6 do
        if uprightBlueRectangles[i] ~= nil then
            if(uprightBlueRectangles.getLinearVelocity ~= nil ) then
                vx, vy = uprightBlueRectangles[i]:getLinearVelocity(); 
                vx = math.abs(vx); vy = math.abs(vy);
                magnitude = math.sqrt(vx ^ 2 + vy ^ 2);   
                
                if magnitude == 0 and uprightBlueRectangles[i].sequence ~= "blueRectGrin" then
                    uprightBlueRectangles[i]:setSequence("blueRectGrin"); 
                    uprightBlueRectangles[i]:play();
                elseif magnitude > 1 and uprightBlueRectangles[i].sequence ~= "blueRectUhOh" then
                    uprightBlueRectangles[i]:setSequence("blueRectUhOh"); 
                    uprightBlueRectangles[i]:play();
                end
                
                if uprightBlueRectangles[i].y > display.contentHeight + shapeOpts.frames[40].width then
                    uprightBlueRectangles[i]:removeSelf(); 
                    uprightBlueRectangles[i] = nil;
                    
                    if blueMotionTimer ~= nil then
                        timer.cancel(blueMotionTimer); 
                        blueMotionTimer = nil;
                    end
                end
            end 
        end
   end
end

--- This function is called every millisecond to test if the green object with a face is moving and change it's facial expressions accordingly
local function getGreenMotion()
    local vx, vy, magnitude;

 -- Check and see if the green box sprite is moving and change its facial expression accordingly
    if greenBox ~= nil then
        if (greenBox.getLinearVelocity ~= nil) then
            vx, vy = greenBox:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);   

            if magnitude == 0 and greenBox.sequence ~= "greenGrin" then
              greenBox:setSequence("greenGrin"); 
              greenBox:play();
            elseif magnitude > 1 and greenBox.sequence ~= "greenUhOh" then
              greenBox:setSequence("greenUhOh"); 
              greenBox:play();
            end
        
            if (greenBox.y > display.contentHeight + shapeOpts.frames[47].height) or (greenBox.x > display.contentWidth + shapeOpts.frames[47].width) then
                greenBox:removeSelf(); 
                greenBox = nil;
                if greenMotionTimer ~= nil then
                    timer.cancel(greenMotionTimer); 
                    greenMotionTimer = nil; 
                end
            end
        end
    end
end

--- This function is called every millisecond to test if any of the red objects with faces are moving and change their facial expressions accordingly
local function getRedMotion()

    local vx, vy, magnitude;
    local redBoxesRemain = false;
     --- Loop through the dark red square sprite objects and if they are moving change their facial expressions accordingly
    for i = 1, 4 do
      if redBoxes[i] ~= nil then
          if ( redBoxes[i].getLinearVelocity ~= nil ) then
              vx, vy = redBoxes[i]:getLinearVelocity(); 
              vx = math.abs(vx); vy = math.abs(vy);
              magnitude = math.sqrt(vx ^ 2 + vy ^ 2);   

              if magnitude == 0 and redBoxes[i].sequence ~= "darkRedFrown" then
                redBoxes[i]:setSequence("darkRedFrown"); 
                redBoxes[i]:play();
              elseif magnitude > 1 and magnitude < 50 and redBoxes[i].sequence ~= "darkRedUhOh" then
                redBoxes[i]:setSequence("darkRedUhOh"); 
                redBoxes[i]:play();
              elseif magnitude > 50 and redBoxes[i].sequence ~= "darkRedSmile" then 
                redBoxes[i]:setSequence("darkRedSmile"); 
                redBoxes[i]:play();
              end

              if redBoxes[i].y > display.contentHeight + shapeOpts.frames[55].height then
                redBoxes[i]:removeSelf(); 
                redBoxes[i] = nil;
              end
          end    
      end
    end
     
    for i = 1, 4 do
      if redBoxes[i] ~= nil then
        redBoxesRemain = true;
      end
    end
      
    if redBoxesRemain == false then
        if redMotionTimer ~= nil then
            timer.cancel(redMotionTimer); 
            redMotionTimer = nil;
        end
    end
end

--- This function is set to start firing every millisecond after the small blue box sprite to the far left is unleashed to track its motion
local function trackSmallBlueBox()

 --- If the small blue box sprite is moving slowly change to "Uh-Oh" facial expression and if faster change to smile
    if smallblueBox ~= nil then
        if smallblueBox.x > 250 then
            smallblueBox:setSequence("smallBlueSmile"); 
            smallblueBox:play();
        end
        
        if smallblueBox.x > (display.contentWidth + (shapeOpts.frames[72].width * 1.2 * 0.6))  then
            if smallblueBox ~= nil then
              smallblueBox:removeSelf(); 
              smallblueBox = nil;
            end

            if uprightBlueRectangles[6] ~= nil then
              physics.removeBody(uprightBlueRectangles[6]); 
              newWidth = (shapeOpts.frames[40].width * 0.8) / 2; 
              newHeight = (shapeOpts.frames[40].height * 1.5) / 2;
              
              objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
              physics.addBody(uprightBlueRectangles[6], "dynamic", {friction = 40, bounce = 0, shape = objectShape} );

              if smallBlueBoxTimer ~= nil then
                timer.cancel(smallBlueBoxTimer); 
                smallBlueBoxTimer = nil;
              end
            end
        end
    end
end

-- This function is called to set the small blue box sprite into motion after the platform holding it back has been removed
local function shootSmallBlueBox()
    if smallblueBox ~= nil then
        smallblueBox:setSequence("smallBlueUhOh"); 
        smallblueBox:play();
        smallblueBox:setLinearVelocity(150, 0);
        smallBlueBoxTimer = timer.performWithDelay(2, trackSmallBlueBox, -1);
    end
end

--- This function is called to remove an object that can be removed by tapping on it is tapped 
local function removeObject(event)

    if event.target.nameTag == "centerPlatform" and blueCenterPlatform ~= nil then
        blueCenterPlatform:removeSelf();
        blueCenterPlatform = nil;
    end 

    if event.target.nameTag == "shortBluePlatform" and shortBluePlatforms[event.target.index] ~= nil then
        shortBluePlatforms[event.target.index]:removeSelf();
        shortBluePlatforms[event.target.index] = nil;
    end

    if event.target.nameTag == "smallBluePlatform" and smallBluePlatform ~= nil then
        smallBluePlatform:removeSelf();
        smallBluePlatform = nil;
        timer.performWithDelay(100, shootSmallBlueBox, 1);
    end

    if event.target.nameTag == "lightRedPlatform" and lightRedPlatform ~= nil then
        lightRedPlatform:removeSelf();
        lightRedPlatform = nil;
    end

    if event.target.nameTag == "blueRect" and uprightBlueRectangles[event.target.index] ~= nill then
        uprightBlueRectangles[event.target.index]:removeSelf(); 
        uprightBlueRectangles[event.target.index] = nil;
    end

end



 ---------------------------------------------------------------------------------------------------------



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

    if phase == "will" then 

    -- Loop through the parameters passed to this scene and put them in the parameters that will be passed to the next scene
        for i = 1, 9 do
            sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
        end
    
        local x, y, newWidth, newHeight; local objectShape;

       --- Blue center platform near the bottom half of the screen -----------------------------------------------------------------
        blueCenterPlatform = display.newImage(imageSheet, 75, display.contentCenterX - 30, display.contentHeight * (3/ 4)); 
        blueCenterPlatform:scale(1.2, 1.6);
        blueCenterPlatform.nameTag = "centerPlatform"
        sceneGroup:insert(blueCenterPlatform)
       ------------------------------------------------------------------------------------------------------------------------------
       
       ---- All of the short half colored blue platforms near the top of the screen ------------------------------------------------------------------------------
        x = (display.contentCenterX / 4) + 60 - 40; 
        y = display.contentCenterY + 25;
        for i = 1, 4 do
            shortBluePlatforms[i] = display.newImage(imageSheet, 16, x, y); 
            shortBluePlatforms[i]:scale(1.5, 2);
            shortBluePlatforms[i].nameTag = "shortBluePlatform"; 
            shortBluePlatforms[i].index = i;

            redBoxes[i] = display.newSprite(imageSheet, shapeSeqData);
            redBoxes[i]:scale(1.5, 2);
            redBoxes[i].x = x; 
            redBoxes[i].y = y - shapeOpts.frames[16].height - shapeOpts.frames[55].height;
            redBoxes[i]:setSequence("darkRedFrown"); 
            redBoxes[i]:play();
            x = x + (shapeOpts.frames[16].width * 1.5) + 25; 
            sceneGroup:insert(shortBluePlatforms[i])
            sceneGroup:insert(redBoxes[i])   
        end 
       --------------------------------------------------------------------------------------------------------------------------------------------------------
       --- The light red platform that hold the green box up --------------------------------------------------------------------------------------------------
        x = blueCenterPlatform.x + (shapeOpts.frames[75].width * 1.2 * 0.5) - 60 + (shapeOpts.frames[16].width * 1.5) + 38;
        lightRedPlatform = display.newImage(imageSheet, 71, x, y);
        lightRedPlatform:scale(1.5, 2);
        lightRedPlatform.nameTag = "lightRedPlatform";
        sceneGroup:insert(lightRedPlatform)
       ---------------------------------------------------------------------------------------------------------------------------------------------------------
       --- The green box sprite near the upper right of the screen ---------------------------------------------------------------------------------------------
        greenBox = display.newSprite(imageSheet, shapeSeqData);
        greenBox:scale(1.5, 2);
        greenBox.x = x; greenBox.y = y - shapeOpts.frames[71].height - shapeOpts.frames[48].height;
        greenBox:setSequence("greenGrin"); 
        greenBox:play();
        sceneGroup:insert(greenBox);
       -----------------------------------------------------------------------------------------------------------------------------------------------------------
       --- the rest of the short blue half colored platforms near the bottom right of the screen -----------------------------------------------------------------
        x = blueCenterPlatform.x + (shapeOpts.frames[75].width * 1.2 * 0.5) - 60; 
        y = blueCenterPlatform.y + 85;
        for i = 5, 6 do
            shortBluePlatforms[i] = display.newImage(imageSheet, 16, x, y);
            shortBluePlatforms[i]:scale(1.5, 2);
            shortBluePlatforms[i].nameTag = "shortBluePlatform"; 
            shortBluePlatforms[i].index = i;
            x = x + (shapeOpts.frames[16].width * 1.5) + 38;
            sceneGroup:insert(shortBluePlatforms[i])
        end 
       -------------------------------------------------------------------------------------------------------------------------------------------------------------

       --- the six upright blue sprites sitting on the center platform -----------------------------------------------------------------------------------------------
        
        x = blueCenterPlatform.x - ((shapeOpts.frames[75].width  * 1.2) / 2) + 63; 
        y = blueCenterPlatform.y - ((shapeOpts.frames[75].height * 1.6) / 2) - ((shapeOpts.frames[40].width * 0.8) / 2);
        for i = 1, 6 do
            uprightBlueRectangles[i] = display.newSprite(imageSheet, shapeSeqData);
            uprightBlueRectangles[i]:scale(0.8, 1.5); 
            uprightBlueRectangles[i]:rotate(-90);
            uprightBlueRectangles[i].x = x; 
            uprightBlueRectangles[i].y = y;
            uprightBlueRectangles[i]:setSequence("blueRectGrin"); 
            uprightBlueRectangles[i]:play();
            uprightBlueRectangles[i].nameTag = "blueRect"; 
            uprightBlueRectangles[i].index = i;
            x = x + 95;
            sceneGroup:insert(uprightBlueRectangles[i])
        end
       ----------------------------------------------------------------------------------------------------------------------------------------------------------------
       -- the very small blue platform holding the small blue box sprite back at the left of the screen ---------------------------------------------------------------
        smallBluePlatform = display.newImage(imageSheet, 17, shapeOpts.frames[72].width + 3 + shapeOpts.frames[17].width * 1.2 * 0.5, y - (shapeOpts.frames[40].width / 2) + 10);
        smallBluePlatform:scale(1.2, 1.2);
        smallBluePlatform.nameTag = "smallBluePlatform";
        sceneGroup:insert(smallBluePlatform)
       ----------------------------------------------------------------------------------------------------------------------------------------------------------------
       --- the small blue box sprite that will be unleashed across the screen -----------------------------------------------------------------------------------------
        smallblueBox = display.newSprite(imageSheet, shapeSeqData);
        smallblueBox:scale(1.2, 1.2);
        smallblueBox.x = ((shapeOpts.frames[72].width * 1.2) / 2) - 2; 
        smallblueBox.y = y - (shapeOpts.frames[40].width / 2) + 10;
        smallblueBox:setSequence("smallBlueGrin"); 
        smallblueBox:play();
        sceneGroup:insert(smallblueBox)
       ----------------------------------------------------------------------------------------------------------------------------------------------------------------
       --- Go through every object created and add it to the physics engine ------------------------------------------------------------------------------------------
        newWidth = (shapeOpts.frames[75].width * 1.2) / 2; 
        newHeight = (shapeOpts.frames[75].height * 1.6) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        physics.addBody( blueCenterPlatform, "static", { friction = 4.5, bounce = 0.3, shape = objectShape } );
        blueCenterPlatform.gravityScale = 0;
        blueCenterPlatform:addEventListener("tap", removeObject);


        newWidth = (shapeOpts.frames[71].width * 1.5) / 2; 
        newHeight = (shapeOpts.frames[75].height * 2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        physics.addBody( lightRedPlatform, "static", { friction = 0.5, bounce = 0.3, shape = objectShape } );
        lightRedPlatform.gravityScale = 0;
        lightRedPlatform:addEventListener("tap", removeObject);


        newWidth = (shapeOpts.frames[17].width * 1.2) / 2; 
        newHeight = (shapeOpts.frames[17].height * 1.2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        physics.addBody( smallBluePlatform, "static", { friction = 0.5, bounce = 0.3, shape = objectShape } );
        smallBluePlatform.gravityScale = 0;
        smallBluePlatform:addEventListener("tap", removeObject);

        newWidth = (shapeOpts.frames[16].width * 1.5) / 2; 
        newHeight = (shapeOpts.frames[16].height * 2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        for i = 1, 5 do
          physics.addBody(shortBluePlatforms[i], "static", { friction = 0.5, bounce = 0.3, shape = objectShape });
          shortBluePlatforms[i].gravityScale = 0;
          shortBluePlatforms[i]:addEventListener("tap", removeObject);
        end
       
        physics.addBody(shortBluePlatforms[6], "static", { friction = 5, bounce = 0.1, shape = objectShape });
        shortBluePlatforms[6].gravityScale = 0;
        shortBluePlatforms[6]:addEventListener("tap", removeObject);

        newWidth = (shapeOpts.frames[55].width * 1.5) / 2; 
        newHeight = (shapeOpts.frames[55].height * 2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        for i = 1, 4 do
            physics.addBody(redBoxes[i], "dynamic", { friction = 0.5, bounce = 0.3, shape = objectShape });
        end
        
        newWidth = (shapeOpts.frames[47].width * 1.5) / 2; 
        newHeight = (shapeOpts.frames[47].height * 2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        physics.addBody(greenBox, "dynamic", { friction = 5, bounce = 0.1, shape = objectShape });
       
        newWidth = (shapeOpts.frames[72].width * 1.2) / 2; 
        newHeight = (shapeOpts.frames[72].height * 1.2) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        physics.addBody(smallblueBox, "dynamic", { density = 2, friction = 0, bounce = 0.8, shape = objectShape });

        smallblueBox.gravityScale = 0;
        newWidth = (shapeOpts.frames[40].width * 0.8) / 2; 
        newHeight = (shapeOpts.frames[40].height * 1.5) / 2;
        objectShape = {-newWidth, -newHeight, newWidth, -newHeight, newWidth, newHeight, -newWidth, newHeight};
        
        for i = 1, 5 do
          physics.addBody(uprightBlueRectangles[i], "dynamic", { friction = 0.5, bounce = 0.3, shape = objectShape });
          uprightBlueRectangles[i]:addEventListener("tap", removeObject);
        end
        
        physics.addBody(uprightBlueRectangles[6], "dynamic", { friction = 2, bounce = 0.1, shape = objectShape });
        uprightBlueRectangles[6]:addEventListener("tap", removeObject);
 ------------------------------------------------------

     -- Start the physics engine and set gravity to 18.8 m/s2 downward

    --physics.setDrawMode("hybrid");

    

    
    elseif phase == "did" then
   
   -- Create image to tap on to go back to the main menu
        levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
        levelSelectImage:scale(1.6, 1.6);
        levelSelectImage:addEventListener("tap", levelSelect); -- Add tap event listener for return to menu screen
        sceneGroup:insert(levelSelectImage);

        message = display.newText("", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
        message:setFillColor(0, 0, 0);
        sceneGroup:insert( message);

        tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
        tryAgainImage.level = "dummy";
        tryAgainImage:scale(1.5, 1.5);
        tryAgainImage.isVisible=false;
        sceneGroup:insert( tryAgainImage);

        continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
        continueImage.level = "level5";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);    

        redMotionTimer    = timer.performWithDelay(1, getRedMotion, -1); -- Start timer to detect motion of dark red squares sprites with faces
        greenMotionTimer  = timer.performWithDelay(1, getGreenMotion, -1); -- Start timer to detect motion of green square sprite with faces
        blueMotionTimer   = timer.performWithDelay(2, getBlueMotion, -1); -- Start timer to detect motion of blue squares sprites with faces
        levelDoneTimer    = timer.performWithDelay(2, levelDone, -1); -- Start timer to continuously check if the level is done with

    end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == "will" then

   --- Remove any display objects that may still be present when the scene is about to go away ----------------------------------------------------
       -------------------------------------------------------------------------------------------------------------------------------------------------------- 

   elseif  phase == "did" then

   ---- If any timers are still alive then cancel them -----------------------------------------------------------------------------------------------------
    if levelDoneTimer ~= nil then

     timer.cancel(levelDoneTimer); levelDoneTimer = nil;

    end
    
    if redMotionTimer ~= nil then

     timer.cancel(redMotionTimer); redMotionTimer = nil;

    end

    if greenMotionTimer ~= nil then

     timer.cancel(greenMotionTimer); greenMotionTimer = nil;

    end

    if smallBlueBoxTimer ~= nil then

     timer.cancel(smallBlueBoxTimer); smallBlueBoxTimer = nil;

    end

    if blueMotionTimer ~= nil then

     timer.cancel(blueMotionTimer); blueMotionTimer = nil;

    end
   -------------------------------------------------------------------------------------------------------------------------------------------------------------

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