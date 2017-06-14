----level design : Tanvi Pawale

local composer = require("composer");
composer.removeScene( "level6", true )
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
local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

local shapeOpts = { frames = {
                               {x = 97,  y = 102, width = 221, height = 26},  -- 1 - long green half-colored rectangular platform
                               {x = 13,  y = 444, width = 76,  height = 51},  -- 2 - green rectangle with frown
                               {x = 92,  y = 444, width = 76,  height = 51},  -- 3 - green rectangle with smile
                               {x = 172, y = 444, width = 76,  height = 51},  -- 4 - green rectangle with laugh
                               {x = 252, y = 444, width = 76,  height = 51},  -- 5 - green rectangle with "uh-oh" face
                               {x = 411, y = 444, width = 76,  height = 51},  -- 6 - light red rectangle with frown
                               {x = 491, y = 444, width = 76,  height = 51},  -- 7 - light red rectangle with smile
                               {x = 571, y = 444, width = 76,  height = 51},  -- 8 - light red rectangle with laugh
                               {x = 651, y = 444, width = 76,  height = 51},  -- 9 - light red rectangle with "uh-oh" 
                             }
                  };

local imageSheet = graphics.newImageSheet("sheet1.png", shapeOpts);

local shapeSeqData = {
                      {name = "greenFrown",  frames = {2}  },
                      {name = "greenSmile",  frames = {3} },
                      {name = "greenLaugh",  frames = {4} },
                      {name = "greenUhoh",   frames = {5} },
                      {name = "redFrown",    frames = {6} },
                      {name = "redSmile",    frames = {7} },
                      {name = "redLaugh",    frames = {8} },
                      {name = "redUhoh",     frames = {9} },
                     };

local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level6", false )     
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
    composer.removeScene( "level6", false )

end
        -----------============== LevelCompleted function ===========
        ---===========================================================
        local function levelCompleted()
            done = true
            for i = 1,2 do
              if (greenBox[i] ~= nil and greenBox[i].nameTag ~= nil ) then
                done = false
              end      
            end

            if(done == false) then 
              for i = 1,2 do
                greenBox[i]:setSequence( "greenLaugh" )
              end
            end
            sceneTransitionOptions.params.levelStatus[6] = "completed"; 
            sceneTransitionOptions.effect = "fromRight";
            message.text = "Success!"


            continueImage.isVisible=true ;
            continueImage:addEventListener("tap", nextLevel);

        end
        -----------============== LevelFailed function ===========
        ---===========================================================
        local function levelFailed()

            sceneTransitionOptions.params.levelStatus[6] = "attempted"; 
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

                  for i = 1, 3 do
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

            for i = 1, 3 do
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
                    
                    if redBox[i].y > (display.contentHeight + 102) then
                        redBox[i]:removeSelf(); 
                        redBox[i] = nil;
                    end
                end
            end

            for i = 1, 2 do  
                if (greenBox[i] ~= nil and greenBox[i].nameTag ~= nil ) then 
                    vx, vy = greenBox[i]:getLinearVelocity(); 
                    vx = math.abs(vx); vy = math.abs(vy);
                    magnitude = math.sqrt(vx ^ 2 + vy ^ 2);

                    if magnitude == 0 and greenBox[i].sequence ~= "greenSmile" then
                        greenBox[i]:setSequence("greenSmile"); 
                    elseif magnitude > 1 and magnitude < 50 and greenBox[i].sequence ~= "greenUhoh" then
                        greenBox[i]:setSequence("greenUhoh"); 
                    elseif magnitude > 50 and greenBox[i].sequence ~= "greenFrown" then 
                        greenBox[i]:setSequence("greenFrown");
                    end  

                    if (greenBox[i].y > display.contentHeight or greenBox[i].x < 0 ) then
                        greenBox[i].nameTag = nil;
                        greenBox[i]:removeSelf(); 
                        greenBox[i] = nil;   
                    end          
                end
            end
 
            for i = 1, 3 do
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
    
      gBox_1 = display.newImageRect( imageSheet, 1, 442, 52 )
      gBox_1.x, gBox_1.y = display.contentWidth/2, display.contentHeight/2+300
      gBox_1.nameTag = "green1"
      physics.addBody( gBox_1, "static" )
      sceneGroup:insert(gBox_1)
      
      objectShape = {-76, -51, 76, -51, 76, 51, -76, 51};

      x = display.contentWidth/2 +100;
      y =  display.contentHeight/2 +121; 
      for i = 1, 2 do 
          greenBox[i] = display.newSprite(imageSheet, shapeSeqData )
          greenBox[i]:setSequence("greenSmile");
          greenBox[i]:scale(2, 2);
          greenBox[i].x = x
          greenBox[i].y = y 
          greenBox[i]:toFront();
          greenBox[i].nameTag = "green"; 
          greenBox[i].index = i;
          x = x - 200;
          physics.addBody( greenBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
          sceneGroup:insert(greenBox[i])
      end

      x = display.contentWidth/2 -200;
      y =  display.contentHeight/2+223; 
      for i = 1, 3 do 
          redBox[i] = display.newSprite(imageSheet, shapeSeqData )
          redBox[i]:setSequence("redFrown");
          redBox[i]:scale(2, 2);
          redBox[i].x = x
          redBox[i].y = y 
          redBox[i]:toFront();
          redBox[i].nameTag = "red"; 
          redBox[i].index = i;
          x = x + 200;
          physics.addBody( redBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
          sceneGroup:insert(redBox[i])
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
        continueImage.level = "level7";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);


        local function bBox_tap(event)
            
            if( (event.target.nameTag == "red" or event.target.nameTag == "green1") and event.target ~= nil) then
                event.target:removeEventListener( "tap", bBox_tap)
                event.target:removeSelf( );
                event.target.nameTag = nil
                event.target = nil
            end

        end
        if(gBox_1 ~= nil) then
            gBox_1:addEventListener( "tap", bBox_tap )
        end
        for i = 1, 3 do 
            if(redBox[i] ~= nil) then
                redBox[i]:addEventListener( "tap", bBox_tap )
            end
        end

        motionTimer = timer.performWithDelay(1, getMotion, -1);

    end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if phase == "will" then
        if(message ~= nil) then 
            message:removeSelf( )
            message = nil
        end

        if(tryAgainImage ~= nil) then 
            tryAgainImage:removeSelf( )
            tryAgainImage = nil
        end

        if(continueImage ~= nil) then 
            continueImage:removeSelf( )
            continueImage = nil
        end

        if(motionTimer ~= nil) then 
            timer.cancel( motionTimer )
            motionTimer = nil
        end
                
        if (levelDoneTimer ~= nil) then
            timer.cancel( levelDoneTimer )
            levelDoneTimer = nil   
        end
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
    elseif phase == "did" then
    
    end

end
 
-- Composer destroy scene function
function scene:destroy(event)
 
   local sceneGroup = self.view
        if(message ~= nil) then 
            message:removeSelf( )
            message = nil
        end

        if(tryAgainImage ~= nil) then 
            tryAgainImage:removeSelf( )
            tryAgainImage = nil
        end

        if(continueImage ~= nil) then 
            continueImage:removeSelf( )
            continueImage = nil
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