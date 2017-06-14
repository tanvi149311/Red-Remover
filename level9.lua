----level Design: Tanvi Pawale

local composer = require("composer");
composer.removeScene( "level9", true )
composer.removeHidden()


local scene = composer.newScene();
local physics = require( "physics")
physics.start();
physics.setGravity(0, 18.8);
--physics.setDrawMode( "hybrid" ) -- Make this new scene

local backgroundImage; 
local continueImage = nil; 
local tryAgainImage = nil; 
local message = nil; 
local levelSelectImage = nil;
local greenBox = {}
local redBox = {}
local bigBlueBox = {}
local blueRect = {}
local tag = nil

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

local shapeOpts = { frames = {
 
                               {x = 448, y = 36,  width = 126, height = 26},  -- 1 - short blue half-colored rectangular platform
                               {x = 14,  y = 233, width = 201, height = 50},  -- 2 - long blue rectangle with grin
                               {x = 14,  y = 233, width = 201, height = 50},  -- 3 - long blue rectangle with frown
                               {x = 221, y = 233, width = 201, height = 50},  -- 4 - long blue rectangle with smile
                               {x = 221, y = 233, width = 201, height = 50},  -- 5 - long blue rectangle with laugh
                               {x = 636, y = 233, width = 201, height = 50},  -- 6 - long blue rectangle with "uh-oh" face
                               {x = 14,  y = 292, width = 151, height = 26},  -- 7 - long blue rectanglular platform with frown
                               {x = 171, y = 292, width = 151, height = 26},  -- 8 - long blue rectanglular platform with smile
                               {x = 326, y = 292, width = 151, height = 26},  -- 9 - long blue rectanglular platform with laugh
                               {x = 483, y = 292, width = 151, height = 26},  -- 10 - long blue rectanglular platform with "uh-oh" face
                               {x = 14,  y = 327, width =  51, height = 51},  -- 11 - blue square with frown
                               {x = 69,  y = 327, width =  51, height = 51},  -- 12 - blue square with grin
                               {x = 123, y = 327, width =  51, height = 51},  -- 13 - blue square with smile
                               {x = 178, y = 327, width =  51, height = 51},  -- 14 - blue square with "uh-oh" face
                               {x = 232, y = 327, width =  51, height = 51},  -- 15- green square with frown
                               {x = 286, y = 327, width =  51, height = 51},  -- 16 - green square with smile
                               {x = 341, y = 327, width =  51, height = 51},  -- 17 - green square with laugh
                               {x = 396, y = 327, width =  51, height = 51},  -- 18 - green square with "uh-oh" face
                               {x = 450, y = 326, width =  50, height = 50},  -- 19 - light red square with frown
                               {x = 505, y = 326, width =  50, height = 50},  -- 20 - light red square with grin
                               {x = 560, y = 326, width =  50, height = 50},  -- 21 - light red square with smile
                               {x = 613, y = 326, width =  51, height = 50},  -- 22 - light red square with "uh-oh" face
                               {x = 668, y = 327, width =  51, height = 51},  -- 23 - dark red square with frown
                               {x = 723, y = 327, width =  51, height = 51},  -- 24 - dark red square with grin
                               {x = 776, y = 327, width =  51, height = 51},  -- 25 - dark red square with smile
                               {x = 829, y = 327, width =  51, height = 51},  -- 26 - dark red square with "uh-oh" face
                              }
                  };
local imageSheet = graphics.newImageSheet("sheet1.png", shapeOpts);

local shapeSeqData = {
                      {name = "bigBlueFrown",    frames = {3} },
                      {name = "bigBlueSmile",    frames = {4} },
                      {name = "bigBlueLaugh",    frames = {5} },
                      {name = "bigBlueUhoh",     frames = {6} },
                      {name = "blueFrown",    frames = {7} },
                      {name = "blueSmile",    frames = {8} },
                      {name = "blueLaugh",    frames = {9} },
                      {name = "blueUhoh",     frames = {10} },
                      {name = "greenFrown",  frames = {15}  },
                      {name = "greenSmile",  frames = {16} },
                      {name = "greenLaugh",  frames = {17} },
                      {name = "greenUhoh",   frames = {18} },
                      {name = "redFrown",    frames = {23} },
                      {name = "redSmile",    frames = {24} },
                      {name = "redLaugh",    frames = {25} },
                      {name = "redUhoh",     frames = {26} },
                     };

local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level9", false )     
end

local function levelSelect()

    if levelDoneTimer ~= nil then
        timer.cancel(levelDoneTimer); 
        levelDoneTimer = nil;
    end

    if(motionTimer ~= nil) then 
        timer.cancel( motionTimer )
        motionTimer = nil
    end
                        
    sceneTransitionOptions.effect = "fade"; 
    sceneTransitionOptions.time = 400;
    composer.removeScene( "levelscreen", false )
    composer.gotoScene("levelscreen", sceneTransitionOptions);
    composer.removeScene( "level9", false )

end
-----------============== LevelCompleted function ===========
 ---===========================================================
local function levelCompleted()
    local done = true;
    local blueAlive = false;
    local count = 0
    for i = 1,2 do
        if (greenBox[i] ~= nil and greenBox[i].nameTag ~= nil) then
            done = false
        end      
    end

    if(done == false) then 
        for i = 1,2 do
            greenBox[i]:setSequence( "greenLaugh" )
        end
    end

    for i = 1,2 do
      if bigBlueBox[i] ~= nil and bigBlueBox[i].nameTag ~= nil then
          blueAlive = true
      end  
    end

    if(blueAlive == true) then 
        for i = 1,2 do
            bigBlueBox[i]:setSequence( "bigBlueLaugh" )
        end
    end

    for i = 1, 9 do
        if (sceneTransitionOptions.params.levelStatus[i] == "completed") then
          count = count + 1;
        end
    end

    if(count == 9) then
      continueImage.level = "endGame";
    else 
      continueImage.level = "levelscreen";
    end
    sceneTransitionOptions.params.levelStatus[9] = "completed"; 
    sceneTransitionOptions.effect = "fromRight";
    message.text = "Success!"
    continueImage.isVisible=true ;
    continueImage:addEventListener("tap", nextLevel);
end
        -----------============== LevelFailed function ===========
        ---===========================================================
local function levelFailed()

    sceneTransitionOptions.params.levelStatus[9] = "attempted"; 
    sceneTransitionOptions.effect = "flip"; 
    sceneTransitionOptions.time = 0;
    message.text = "Failed!"
    tryAgainImage.isVisible=true ;
    tryAgainImage:addEventListener("tap", nextLevel);

end

-----------============== LevelDone function ===========
---===========================================================
function levelDone()
    local done = false
    for i = 1,2 do
        if (greenBox[i] ~= nil and greenBox[i].nameTag ~= nil ) then

            for i = 1, 2 do
              if redBox[i] ~= nil and redBox[i].nameTag ~= nil then
                  done = true;
              end
            end

            if (done == false) then 
                if(motionTimer ~= nil) then 
                    timer.cancel( motionTimer )
                    motionTimer = nil
                end
                if (levelDoneTimer ~= nil) then
                    timer.cancel( levelDoneTimer )
                    levelDoneTimer = nil   
                end
                levelCompleted();
            end  
        else 
            if(motionTimer ~= nil) then 
                timer.cancel( motionTimer )
                motionTimer = nil
            end
            if (levelDoneTimer ~= nil) then
                timer.cancel( levelDoneTimer )
                levelDoneTimer = nil   
            end
            levelFailed();    

        end 
    end  
end

-----------============== getMotion function ===========
---===========================================================
local function getMotion()
            
    local vx, vy, magnitude;
    local redBoxesRemain = false;

    for i = 1, 2 do
        if redBox[i] ~= nil and redBox[i].nameTag ~= nil then
            vx, vy = redBox[i]:getLinearVelocity(); 
            vx = math.abs(vx); vy = math.abs(vy);
            magnitude = math.sqrt(vx ^ 2 + vy ^ 2);   

            if magnitude == 0 and redBox[i].sequence ~= "redFrown" then
                redBox[i]:setSequence("redFrown"); 
            elseif magnitude > 1 and magnitude < 50 and redBox[i].sequence ~= "redUhoh" then
                redBox[i]:setSequence("redUhoh"); 
            elseif magnitude > 50 and redBox[i].sequence ~= "redSmile" then 
                redBox[i]:setSequence("redSmile");
            end
                    
            if (redBox[i].y > display.contentHeight or redBox[i].x < 0 or redBox[i].y < 0  or redBox[i].x > display.contentWidth) then
                redBox[i]:removeSelf(); 
                redBox[i] = nil;
            end
        end
    end

    for i = 1, 2 do  
        if (greenBox[i] ~= nil and greenBox[i].nameTag ~= nil ) then 
            if(greenBox[i] ~= nil) then 
              vx, vy = greenBox[i]:getLinearVelocity(); 
              vx = math.abs(vx); vy = math.abs(vy);
             magnitude = math.sqrt(vx ^ 2 + vy ^ 2);
            elseif(greenBox[i] == nil) then
              magnitude = nil
            end
            if magnitude == 0 and greenBox[i].sequence ~= "greenSmile" then
                greenBox[i]:setSequence("greenSmile"); 
            elseif magnitude > 1 and magnitude < 50 and greenBox[i].sequence ~= "greenUhoh" then
                greenBox[i]:setSequence("greenUhoh"); 
            elseif magnitude > 50 and greenBox[i].sequence ~= "greenFrown" then 
                greenBox[i]:setSequence("greenFrown");
            end  

            if (greenBox[i].y > display.contentHeight or greenBox[i].x < 0 or greenBox[i].y < 0  or greenBox[i].x > display.contentWidth) then
                greenBox[i].nameTag = nil;
                greenBox[i]:removeSelf(); 
                greenBox[i] = nil;   
            end          
        end
    end
    
    for i = 1, 2 do  

        if (bigBlueBox[i] ~= nil and bigBlueBox[i].nameTag ~= nil ) then 
            if(bigBlueBox[i].getLinearVelocity ~= nil ) then
                vx, vy = bigBlueBox[i]:getLinearVelocity(); 
                vx = math.abs(vx); vy = math.abs(vy);
                magnitude = math.sqrt(vx ^ 2 + vy ^ 2);

                if magnitude == 0 and bigBlueBox[i].sequence ~= "bigBlueSmile" then
                    bigBlueBox[i]:setSequence("bigBlueSmile"); 
                elseif magnitude > 1 and magnitude < 50 and bigBlueBox[i].sequence ~= "bigBlueUhoh" then
                    bigBlueBox[i]:setSequence("bigBlueUhoh"); 
                elseif magnitude > 50 and bigBlueBox[i].sequence ~= "bigBlueFrown" then 
                    bigBlueBox[i]:setSequence("bigBlueFrown");
                end  
            end
        end
    end 

    for i = 1, 2 do
        if redBox[i] ~= nil then
            redBoxesRemain = true;
        end
    end
  
    if redBoxesRemain == false then
        if motionTimer ~= nil then
            timer.cancel(motionTimer); 
            motionTimer = nil;
        end
    end

    levelDoneTimer = timer.performWithDelay(1, levelDone);

end


function scene:create(event)
 
    local sceneGroup = self.view;
    backgroundImage = display.newImage("bg.png", display.contentCenterX, display.contentCenterY);
    backgroundImage:scale(display.contentWidth / backgroundImage.contentWidth, display.contentHeight / backgroundImage.contentHeight);
    sceneGroup:insert(backgroundImage); -- Insert background image into the scene group  

    levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
    levelSelectImage:scale(1.6, 1.6);
    levelSelectImage:addEventListener("tap", levelSelect); 
    sceneGroup:insert( levelSelectImage )
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
    
    -------------------four purple Balls ================

       local bBall_1 = display.newCircle( display.contentWidth/2-180, display.contentHeight/2-184, 30 )
       bBall_1:setFillColor( 0.5, 0, 1 )
       physics.addBody( bBall_1, "static" )
       sceneGroup:insert(bBall_1)


       local bBall_2 = display.newCircle( display.contentWidth/2+180, display.contentHeight/2-184, 30 )
       bBall_2:setFillColor( 0.5, 0, 1 )
       physics.addBody( bBall_2, "static" )
       sceneGroup:insert(bBall_2)

       local bBall_3 = display.newCircle( display.contentWidth/2-180, display.contentHeight/2+184, 30 )
       bBall_3:setFillColor( 0.5, 0, 1 )
       physics.addBody( bBall_3, "static" )
       sceneGroup:insert(bBall_3)


       local bBall_4 = display.newCircle( display.contentWidth/2+180, display.contentHeight/2+184, 30 )
       bBall_4:setFillColor( 0.5, 0, 1 )   
       physics.addBody( bBall_4, "static" )
       sceneGroup:insert(bBall_4)

       blueStatic1 = display.newImageRect( imageSheet, 1, 252, 52 )
       sceneGroup:insert(blueStatic1)
       blueStatic1.x, blueStatic1.y = display.contentWidth/2, display.contentHeight/2-372
       blueStatic1.tag = "blueStatic1"
       physics.addBody( blueStatic1, "static" )

       blueStatic2 = display.newImageRect( imageSheet, 1, 252, 52 )
       sceneGroup:insert(blueStatic2)
       blueStatic2.x, blueStatic2.y = display.contentWidth/2, display.contentHeight/2+372
       blueStatic2.tag = "blueStatic2"
       physics.addBody( blueStatic2, "static" )

       halfBlueBox_1 = display.newImageRect( imageSheet, 1, 102, 52 )
       halfBlueBox_1.rotation = 90
       sceneGroup:insert(halfBlueBox_1)
       halfBlueBox_1.x, halfBlueBox_1.y = display.contentWidth/2+180, display.contentHeight/2 - 70
       halfBlueBox_1.tag = "halfBlueBox_1"
       physics.addBody( halfBlueBox_1, "static" )
    
       halfBlueBox_2 = display.newImageRect( imageSheet, 1, 102, 52 )
       halfBlueBox_2.rotation = 90
       sceneGroup:insert(halfBlueBox_2)
       halfBlueBox_2.x, halfBlueBox_2.y = display.contentWidth/2-180, display.contentHeight/2 +70
       halfBlueBox_2.tag = "halfBlueBox_2"
       physics.addBody( halfBlueBox_2, "static" )
      
      objectShape = {-201, -102, 201, -102, 201, 102, -201, 102};
      x = display.contentWidth/2 ;
      y =  display.contentHeight/2-500; 
      for i = 1, 2 do 
          bigBlueBox[i] = display.newSprite(imageSheet, shapeSeqData )
          bigBlueBox[i]:setSequence("bigBlueSmile");
          bigBlueBox[i]:scale(2, 4);
          bigBlueBox[i].x = x
          bigBlueBox[i].y = y 
          bigBlueBox[i]:toFront();
          bigBlueBox[i].nameTag = "Bigblue"; 
          bigBlueBox[i].index = i;
          y = y + 1000;
          
          physics.addBody( bigBlueBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
          if(i == 1) then
            bigBlueBox[i].gravityScale = 1;
          else
            bigBlueBox[i].rotation = 180
            bigBlueBox[i].gravityScale = -1;
          end
          sceneGroup:insert(bigBlueBox[i])
      end

      objectShape = {-51, -51, 51, -51, 51, 51, -51, 51};

      x = display.contentWidth/2 ;
      y =  display.contentHeight/2-295; 
      for i = 1, 2 do 
          greenBox[i] = display.newSprite(imageSheet, shapeSeqData )
          greenBox[i]:setSequence("greenSmile");
          greenBox[i]:scale(2, 2);
          greenBox[i].x = x
          greenBox[i].y = y 
          greenBox[i]:toFront();
          greenBox[i].nameTag = "green"; 
          greenBox[i].index = i;
          y = y + 590;
          
          physics.addBody( greenBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
          if(i == 1) then
            greenBox[i].gravityScale = -1;
          else
            greenBox[i].rotation = 180
            greenBox[i].gravityScale = 1;
          end
          sceneGroup:insert(greenBox[i])
      end


      x = display.contentWidth/2 ;
      y =  display.contentHeight/2-193; 
      for i = 1, 2 do 
          redBox[i] = display.newSprite(imageSheet, shapeSeqData )
          redBox[i]:setSequence("redFrown");
          redBox[i]:scale(2, 2);
          redBox[i].x = x
          redBox[i].y = y 
          redBox[i]:toFront()
          redBox[i].nameTag = "red"; 
          redBox[i].index = i;
          y = y + 386;
          
          physics.addBody( redBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
          if(i == 1) then
            redBox[i].gravityScale = -1;
          else
            redBox[i].rotation = 180
            redBox[i].gravityScale = 1;
          end
          sceneGroup:insert(redBox[i])
      end

      objectShape = {-100, -26, 100, -26, 100, 26, -100, 26};
      x = display.contentWidth/2 +306 ;
      y =  display.contentHeight/2-70; 
      for i = 1, 2 do 
          blueRect[i] = display.newSprite(imageSheet, shapeSeqData )
          blueRect[i]:setSequence("blueSmile");
          blueRect[i]:scale(1.3, 2);
          blueRect[i].x = x
          blueRect[i].y = y 
          blueRect[i]:toFront();
          blueRect[i].nameTag = "blue"; 
          blueRect[i].index = i;
          x = x - 612;
          y = y + 140;
          sceneGroup:insert(blueRect[i])
      end

    
    elseif phase == "did" then

        message = display.newText("", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
        message:setFillColor(0, 0, 0);
        sceneGroup:insert( message);

        tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
        tryAgainImage.level = "dummy";
        tryAgainImage:scale(1.5, 1.5);
        tryAgainImage.isVisible=false;
        sceneGroup:insert( tryAgainImage);

        continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
        continueImage.level = " ";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);

        local function setForce(event)
            objectShape = {-100, -26, 100, -26, 100, 26, -100, 26};
            if (tag == "halfBlueBox_1") then
                physics.addBody( blueRect[1], "dynamic", {friction = 0.5, shape = objectShape})
                blueRect[1].gravityScale = 0.0
                blueRect[1]:applyForce( -60, 0,  blueRect[1].x, blueRect[1].y )
            elseif (tag == "halfBlueBox_2") then
                physics.addBody( blueRect[2], "dynamic",{friction = 0.5, shape = objectShape})
                blueRect[2].gravityScale = 0.0
                blueRect[2]:applyForce( 60, 0,  blueRect[2].x, blueRect[2].y )
            end
       end

       local function bBox_tap(event)
            tag = event.target.tag
            event.target:removeEventListener( "tap", bBox_tap )
            event.target:removeSelf( );
            if (tag == "halfBlueBox_1") then
              timer.performWithDelay( 200, setForce )
            elseif (tag == "halfBlueBox_2") then
              timer.performWithDelay( 200, setForce )
            end
            event.target = nil

       end

        if(blueStatic1 ~= nil) then
          blueStatic1:addEventListener( "tap", bBox_tap )
        end
        if(blueStatic2 ~= nil) then
          blueStatic2:addEventListener( "tap", bBox_tap)
        end
        if(halfBlueBox_1 ~= nil) then
          halfBlueBox_1:addEventListener( "tap", bBox_tap )
        end
        if(halfBlueBox_2 ~= nil) then
          halfBlueBox_2:addEventListener( "tap", bBox_tap )
        end
        if(bigBlueBox[1] ~= nil) then
          bigBlueBox[1]:addEventListener( "tap", bBox_tap )
        end
        if(bigBlueBox[2] ~= nil) then
          bigBlueBox[2]:addEventListener( "tap", bBox_tap )
        end
   --end

        motionTimer = timer.performWithDelay(1, getMotion, -1);

   end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if phase == "will" then
        -- if(message ~= nil) then 
        --     message:removeSelf( )
        --     message = nil
        -- end

        -- if(tryAgainImage ~= nil) then 
        --     tryAgainImage:removeSelf( )
        --     tryAgainImage = nil
        -- end

        -- if(continueImage ~= nil) then 
        --     continueImage:removeSelf( )
        --     continueImage = nil
        -- end

        -- if(motionTimer ~= nil) then 
        --     timer.cancel( motionTimer )
        --     motionTimer = nil
        -- end
                
        -- if (levelDoneTimer ~= nil) then
        --     timer.cancel( levelDoneTimer )
        --     levelDoneTimer = nil   
        -- end
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif phase == "did" then
    
    end

end
 
-- Composer destroy scene function
function scene:destroy(event)
 
   local sceneGroup = self.view
        -- if(message ~= nil) then 
        --     message:removeSelf( )
        --     message = nil
        -- end

        -- if(tryAgainImage ~= nil) then 
        --     tryAgainImage:removeSelf( )
        --     tryAgainImage = nil
        -- end

        -- if(continueImage ~= nil) then 
        --     continueImage:removeSelf( )
        --     continueImage = nil
        -- end
 
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