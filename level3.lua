---- Level design : Tanvi Pawale


local composer = require("composer");
composer.removeScene( "level3", true )
composer.removeHidden()

local scene = composer.newScene(); -- Make this new scene

local physics = require ("physics"); 
physics.start();
physics.setGravity(0, 18.8);
--physics.setScale( 10 )
--physics.setDrawMode( "hybrid" )

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

local backgroundImage; 
local continueImage = nil; 
local tryAgainImage = nil; 
local message = nil; 
local levelSelectImage = nil;
redBox = {}

local shapeOpts = { frames = {
                               {x = 97,  y = 102, width = 221, height = 26},  -- 1 - long green half-colored rectangular platform
                               {x = 183, y = 141, width = 51,  height = 51},  -- 2 - light red half-colored square 
                               {x = 232, y = 327, width =  51, height = 51},  -- 3 - green square with frown
                               {x = 286, y = 326, width =  51, height = 51},  -- 4 - green square with smile
                               {x = 341, y = 327, width =  51, height = 51},  -- 5 - green square with laugh
                               {x = 396, y = 327, width =  51, height = 51},  -- 6 - green square with "uh-oh" face
                               {x = 450, y = 326, width =  50, height = 50},  -- 7 - light red square with frown
                               {x = 505, y = 326, width =  50, height = 50},  -- 8 - light red square with smile
                               {x = 560, y = 326, width =  50, height = 50},  -- 9 - light red square with laugh
                               {x = 613, y = 326, width =  51, height = 50},  -- 10 - light red square with "uh-oh" face
                              }
                  };

local imageSheet = graphics.newImageSheet("sheet1.png", shapeOpts);

local shapeSeqData = {
                      {name = "greenFrown",  frames = {3}  },
                      {name = "greenSmile",  frames = {4} },
                      {name = "greenLaugh",  frames = {5} },
                      {name = "greenUhoh",   frames = {6} },
                      {name = "redFrown",    frames = {7} },
                      {name = "redSmile",    frames = {8} },
                      {name = "redLaugh",    frames = {9} },
                      {name = "redUhoh",     frames = {10} },
                     };

local function nextLevel(event)
    composer.removeScene( event.target.level, false )
    composer.gotoScene(event.target.level, sceneTransitionOptions);
    composer.removeScene( "level3", false )     
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
    composer.removeScene( "level3", false )

end

        -----------============== LevelCompleted function ===========
        ---===========================================================
        local function levelCompleted()
            if(gBox_3 ~= nil) then
                gBox_3:setSequence( "greenLaugh" )
            end

            sceneTransitionOptions.params.levelStatus[3] = "completed"; 
            sceneTransitionOptions.effect = "fromRight";
            message.text = "Success!"
            continueImage.isVisible=true ;
            continueImage:addEventListener("tap", nextLevel);

        end
        -----------============== LevelFailed function ===========
        ---===========================================================
        local function levelFailed()

            sceneTransitionOptions.params.levelStatus[3] = "attempted"; 
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

            if (gBox_3 ~= nil and gBox_3.nameTag ~= nil ) then

                for i = 1, 5 do
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

        -----------============== getMotion function ===========
        ---===========================================================
        local function getMotion()
            
            local vx, vy, magnitude;
            local redBoxesRemain = false;

            for i = 1, 5 do
                if redBox[i] ~= nil and redBox[i].nameTag ~= nil then
                    if(redBox[i].getLinearVelocity ~= nil) then
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
                            redBox[i]:removeSelf(); redBox[i] = nil;
                        end
                    end
                end
            end

            if (gBox_3 ~= nil and gBox_3.nameTag ~= nil ) then 
                if (gBox_3.getLinearVelocity ~= nil) then
                    vx, vy = gBox_3:getLinearVelocity(); 
                    vx = math.abs(vx); vy = math.abs(vy);
                    magnitude = math.sqrt(vx ^ 2 + vy ^ 2);

                    if magnitude == 0 and gBox_3.sequence ~= "greenSmile" then
                        gBox_3:setSequence("greenSmile"); 
                    elseif magnitude > 1 and magnitude < 50 and gBox_3.sequence ~= "greenUhoh" then
                        gBox_3:setSequence("greenUhoh"); 
                    elseif magnitude > 50 and gBox_3.sequence ~= "greenFrown" then 
                        gBox_3:setSequence("greenFrown");
                    end  

                    if (gBox_3.y > display.contentHeight or gBox_3.x < 0 ) then
                        gBox_3.nameTag = nil;
                        gBox_3:removeSelf(); 
                        gBox_3 = nil;   
                    end 
                end         
            end
 
            for i = 1, 5 do
                if redBox[i] ~= nil then
                    redBoxesRemain = true;
                end
            end

            if (rBox_1 ~= nil) then
                redBoxesRemain = true
            end
  
            if redBoxesRemain == false then
                if motionTimer ~= nil then
                    timer.cancel(motionTimer); 
                    motionTimer = nil;
                end
            end

            

            levelDoneTimer = timer.performWithDelay(1, levelDone);

        end



---- Put some display objects in the group scene
function scene:create(event)
 
    local sceneGroup = self.view;
    backgroundImage = display.newImage("bg.png", display.contentCenterX, display.contentCenterY);
    backgroundImage:scale(display.contentWidth / backgroundImage.contentWidth, display.contentHeight / backgroundImage.contentHeight);
    sceneGroup:insert(backgroundImage); -- Insert title screen image into the scene group  
 
    levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
    levelSelectImage:scale(1.6, 1.6);
    levelSelectImage:addEventListener("tap", levelSelect);
    sceneGroup:insert( levelSelectImage )

end

-- Nothing to do in this function
function scene:show(event)
 
    local sceneGroup = self.view;
    local phase = event.phase;
    local scene;

    if phase == "will" then 

        for i = 1, 9 do
            sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
        end
    
        rBox_1 = display.newImageRect( imageSheet, 2, 202, 42 )
        sceneGroup:insert(rBox_1)
        rBox_1.x, rBox_1.y = display.contentWidth/2-200, display.contentHeight/2+400
        rBox_1.nameTag = "red"
        rBox_1.index = 6
        physics.addBody( rBox_1, "static" )

        objectShape = {-51, -51, 51, -51, 51, 51, -51, 51};

        x = display.contentWidth/2 -200;
        y =  display.contentHeight/2 +226; 
        for i = 3, 5 do 
            redBox[i] = display.newSprite(imageSheet, shapeSeqData )
            redBox[i]:setSequence("redFrown");
            redBox[i]:scale(2, 2);
            redBox[i].x = x
            redBox[i].y = y 
            redBox[i]:toFront();
            redBox[i].nameTag = "red"; 
            redBox[i].index = i;
            y = y - 102;
            physics.addBody( redBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
            sceneGroup:insert(redBox[i])
        end


        x = display.contentWidth/2 - 130
        y =  display.contentHeight/2 +328 
        for i = 1, 2 do 
            redBox[i] = display.newSprite(imageSheet, shapeSeqData )
            redBox[i]:setSequence("redFrown");
            redBox[i]:scale(2, 2);
            redBox[i].x = x
            redBox[i].y = y 
            redBox[i]:toFront();
            redBox[i].nameTag = "red"; 
            redBox[i].index = i;
            x = x - 140;
            physics.addBody( redBox[i], "dynamic", {friction = 0.5, shape = objectShape} )
            sceneGroup:insert(redBox[i])
        end

        gBox_1 = display.newImageRect( imageSheet, 1, 202, 42 )
        gBox_1.x, gBox_1.y = display.contentWidth/2+200, display.contentHeight/2+400
        gBox_1.tag = "green1"
        physics.addBody( gBox_1, "static" )
        sceneGroup:insert(gBox_1)

        gBox_2 = display.newImageRect( imageSheet, 1, 202, 42 )
        gBox_2.rotation = 90
        gBox_2.x, gBox_2.y = display.contentWidth/2+300, display.contentHeight/2+300
        gBox_2.tag = "green2"
        physics.addBody( gBox_2, "static" )
        sceneGroup:insert(gBox_2)

        gBox_3 = display.newSprite(imageSheet, shapeSeqData )
        gBox_3:setSequence("greenSmile");
        gBox_3:scale(2, 2);
        gBox_3.x = display.contentWidth/2-200;
        gBox_3.y = display.contentHeight/2-80; 
        gBox_3:toFront();
        gBox_3.nameTag = "green"; 
        physics.addBody( gBox_3, "dynamic", {friction = 0.5, shape = objectShape} )
        sceneGroup:insert(gBox_3)
    --- PUT CODE HERE -------------------------------------------------------------------------------

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
        continueImage.level = "level4";
        continueImage:scale(1.9, 1.9);
        continueImage.isVisible=false;
        sceneGroup:insert( continueImage);

        -----------============== Box tap listener function ===========
        ---===========================================================
        local function bBox_tap(event)
            
            if(event.target.nameTag == "red" and event.target ~= nil) then
                
                event.target:removeEventListener( "tap", bBox_tap)
                event.target:removeSelf( );
                event.target.nameTag = nil
                event.target = nil
            end

        end
        if(rBox_1 ~= nil) then
            rBox_1:addEventListener( "tap", bBox_tap )
        end
        for i = 1, 5 do 
            if(redBox[i] ~= nil) then
                redBox[i]:addEventListener( "tap", bBox_tap )
            end
        end

        motionTimer = timer.performWithDelay(1, getMotion, -1); -- Start timer to detect motion of red squares sprites with faces
        

    end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if phase == "will" then


        
    elseif  phase == "did" then

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