-- Author: Rakesh
-- CS 571 Final Project  Level 8 for Red Remover Game 
-- Batch Spring 2016
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
composer.removeScene( "level8", true )
composer.recycleOnSceneChange = true;

local scene = composer.newScene(); -- Make this new scene

-- get the physics 
local physics = require("physics"); 
physics.start(); 
physics.setDrawMode("normal"); 

local sceneTransitionOptions = {
                                effect = "fromRight", -- slide next level in from the right
                                time = 800, -- do the slide in a period of 800 milliseconds
                                params = {levelStatus = {}}
                               };

local backgroundImage;  -- For background image
local continueImage = nil;  -- for continue option
local tryAgainImage = nil;  -- for try again option
local message = nil;        -- contain the success or failed message
local levelSelectImage = nil; -- level select option

-- Boxes required reference
local allObjects={}; -- Keep the all objects references which created on screen
local indexTotal=0; -- keep track of number

local checkStatus; -- function declaration

local remObjCount=3; -- all red boxes and platform
local nonRemObjCount=1; -- all green boxes or blue boxes for condition check

local statusFlag=0; -- update this flag when either level failed or success.
local staticCollisionFlag=0; -- For avoid unnecessory static collision

--{objID=nil,name="greenBox",removeable=0,motion=0,mandatory=0,newWidth=0,newHeight=0}
-- Following are the index id which we can refer to access information about create objects and stred in allObjects{}
local objID=1;        -- keep the actual object reference
local name=2;         -- name of the objects
local removeable=3;   -- objects is removeable or not
local motion =4;      -- object has motion or not
local mandatory=5;    -- object is mandatory to remove or not
local newWidth=6;     -- After scaling new width
local newHeight=7;    ---- After scaling new Height
local affectedObject=8; -- Affected object once an event occur on this object
local rotationFlag=9;  -- if we rotate the actual image 



-- init the object value for each image obj
local function initObj( )
  allObjects[indexTotal][objID]=nil;
  allObjects[indexTotal][name]="default";
  allObjects[indexTotal][removeable]=0;
  allObjects[indexTotal][motion]=0;
  allObjects[indexTotal][mandatory]=0;
  allObjects[indexTotal][newWidth]=0;
  allObjects[indexTotal][newHeight]=0;
  allObjects[indexTotal][rotationFlag]=0;
  allObjects[indexTotal][affectedObject]=nil;
end


-- Collision Listener
local function collisionListener(event)

  --print( "collisionListener" )
  local vx = 5; vy=5;
  local tempObjGreen=nil;
  local tempObjTarget=nil;
  
    -- set the moved on as target object and other as 
    if (event.other.tag == "green") then
      tempObjGreen = event.other; 
      tempObjTarget = event.target  
    else
        tempObjGreen = event.target
        tempObjTarget = event.other 
    end
    -- need to reset for kinematic object
    if(event.other.bodyType == "kinematic") then
      tempObjTarget = event.target;
      tempObjGreen = event.other;
      vx=15; -- set the x force factor
    end
      
    -- Collison with dynamic or kinematic objects                                           -- 
    if ((tempObjGreen.bodyType == "dynamic") or (tempObjGreen.bodyType == "kinematic")) then
      -- find the index id and get force factor
      for i=1,indexTotal do
        if( allObjects[i] ~= nil and tempObjTarget == allObjects[i][objID] and allObjects[i][affectedObject] ~= nil) then
          vx=allObjects[i][affectedObject][2]*vx;
          vy=allObjects[i][affectedObject][3]*vy;
        end  
      end
      -- set velocity
      tempObjTarget:setLinearVelocity( vx, vy );
      tempObjGreen:setLinearVelocity( vx, vy );
      --print( "debug level8 dynamic collision ");
      --[[if (tempObjGreen.tag == "green") then
        print( "other is green" );
      else
        print( "other is not green" );
      end--]]

      -- If other object is kinematic then need to give some force to affacted object also
      if (event.other.bodyType == "kinematic") then
        local j=0;
        for i=1,indexTotal do
          if( allObjects[i] ~= nil and allObjects[i][affectedObject] ~= nil and event.other == allObjects[i][objID]) then
            j=allObjects[i][affectedObject][1];
            vx=allObjects[i][affectedObject][2]*10;
            vy=allObjects[i][affectedObject][3]*5;
            --print( "Debug j = " ..j.." - ".. vx .. " - ".. vy );
            break;
          end  
        end
          --print( "debug addeding object again" )
          allObjects[j][objID].isSensor=true;
          allObjects[j][objID]:setLinearVelocity( vx, vy );
        --end
      end
    end
    -- static collision
    if (event.other.bodyType == "static" and staticCollisionFlag ==0 ) then

      staticCollisionFlag =1; -- update static collision flag
      event.target:setLinearVelocity( 0, 0 );
    end
end

---- Tap Listener ------
local function tapListener( event )
  local mFlag=0;
  local xF;
  local yF;

  --if(event.phase == 'began') then
    if(event.target ~= nil) then

      -- Find out affected object
      for i=1,indexTotal do 
        if (allObjects[i] ~= nil and event.target == allObjects[i][objID] and allObjects[i][removeable] == 1) then
          if (allObjects[i][affectedObject] ~= nil ) then
            --print( "enter mFlag" )
              mFlag= allObjects[i][affectedObject][1]
              xF=allObjects[i][affectedObject][2]
              yF=allObjects[i][affectedObject][3]
            --print( mFlag .. " - "..xF .. " - ".. yF .. " - " )
          end
          -- update counter
          if(event.target.tag == "blue") then
            remObjCount=remObjCount-1;
          end
          -- remove object
          --print( "debug removing i = "..i );
          allObjects[i][objID]:removeSelf( );
          allObjects[i][objID]=nil;
          allObjects[i]=nil;
          
        end
      end
    end
    -- Give some motion to affacted object
    if(mFlag ~= 0) then
      --print( mFlag .. " - "..xF .. " - ".. yF )
      if(allObjects[mFlag][objID] ~= nil and allObjects[mFlag][motion] == 1) then
         physics.addBody( allObjects[mFlag][objID], "dynamic");
            allObjects[mFlag][objID]:addEventListener("collision",collisionListener)
            allObjects[mFlag][objID].isSensor=true;

            if (allObjects[mFlag][objID].tag == "green") then -- need to change the for green box x force
              xF=0;
              --print( "debug level8 mFlag "..mFlag.. " xF = ",xF );
            end
            
         if (allObjects[mFlag][affectedObject] ~= nil) then
            --print( "static" )
            physics.addBody( allObjects[allObjects[mFlag][affectedObject][1]][objID], "static");
         else  -- set our self velocity for collision
            allObjects[mFlag][affectedObject]={mFlag,xF,yF};
         end       
         
        allObjects[mFlag][objID]:applyForce( xF, yF,allObjects[mFlag][objID].x,allObjects[mFlag][objID].y )
        --print( "apply force" )
      end
    end  
    -- timer for checking level success of failed

  -- Start timer for status check
  if(timerObj == nil and (remObjCount ==2 ) ) then
    --print( "levle 4 start timer timerObj" );
    local i=0;
    timerObj=timer.performWithDelay( 2000, function(  )
                                            if(i>0) then 
                                              checkStatus();
                                            else
                                              i=i+1;
                                            end
                                    end 
                                    ,-1 );
  end

  --end
end
-- Tap listener end


-- Update the object value after creation of the object
local function updateValues(nameT, xScale, yScale, remFlag, motionFlag, manFlag,rotFlag, affObj)
  local tempObj=allObjects[indexTotal];

  tempObj[newWidth]=tempObj[objID].width*xScale;
  tempObj[newHeight]=tempObj[objID].height*yScale;
  tempObj[rotationFlag]=rotFlag;

  -- updateing actual object width and height based on rotation and height
  if (rotFlag == 1) then
    tempObj[objID].width=tempObj[newHeight]
    tempObj[objID].height=tempObj[newWidth];
  else
    tempObj[objID].width=tempObj[newWidth]
    tempObj[objID].height=tempObj[newHeight];
  end  
 
 -- set some other param
  tempObj[name]=nameT;
  tempObj[removeable]=remFlag;
  tempObj[motion]=motionFlag;
  tempObj[mandatory]=manFlag;
  tempObj[affectedObject]=affObj;
 
 -- add listener
  if (remFlag == 1) then
    tempObj[objID]:addEventListener( "tap", tapListener )
  end  
  if(motionFlag  == 0 and remFlag == 0) then
    physics.addBody( tempObj[objID], "static")
  end

end  

-- Prepare for new object creation
local function callInit()
     indexTotal =indexTotal+1;

     allObjects[indexTotal]={}
     initObj();
end

--------------
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
                               {x = 501, y = 79,  width = 51,  height = 51},  -- 12 - green half-colored square
                               {x = 73,  y = 166, width = 101, height = 26},  -- 13 - short light red half-colored rectangular platform
                               {x = 183, y = 141, width = 51,  height = 51},  -- 14 - light red half-colored square 
                               {x = 448, y = 36,  width = 126, height = 26},  -- 15 - short blue half-colored rectangular platform
                               {x = 654, y = 36,  width = 51,  height = 26},  -- 16 - very short blue half-colored rectangular platform
                               {x = 239, y = 36,  width = 26,  height = 26},  -- 17 - small blue half-colored square
                               {x = 15,  y = 206, width = 25,  height = 17},  -- 18 - dark red frown
                               {x = 46,  y = 206, width = 25,  height = 17},  -- 19 - dark red grin
                               {x = 78,  y = 206, width = 25,  height = 17},  -- 20 - dark red smile
                               {x = 108, y = 206, width = 25,  height = 17},  -- 21 - dark red "Uh-Oh" face
                               {x = 143, y = 206, width = 25,  height = 17},  -- 22 - light red frown
                               {x = 174, y = 206, width = 25,  height = 17},  -- 23 - light red grin
                               {x = 206, y = 206, width = 25,  height = 17},  -- 24 - light red smile
                               {x = 236, y = 206, width = 25,  height = 17},  -- 25 - light red "Uh-Oh" face
                               {x = 271, y = 206, width = 25,  height = 17},  -- 26 - green frown
                               {x = 302, y = 206, width = 25,  height = 17},  -- 27 - green grin
                               {x = 334, y = 206, width = 25,  height = 17},  -- 28 - green smile
                               {x = 364, y = 206, width = 25,  height = 17},  -- 29 - green "Uh-Oh" face
                               {x = 396, y = 206, width = 25,  height = 17},  -- 30 - blue frown
                               {x = 427, y = 206, width = 25,  height = 17},  -- 31 - blue grin
                               {x = 459, y = 206, width = 25,  height = 17},  -- 32 - blue smile
                               {x = 489, y = 206, width = 25,  height = 17},  -- 33 - blue "Uh-Oh" face
                             }
                  };


local imageSheet = graphics.newImageSheet("sheetrks.png", shapeOpts);

-- remove all the remaining objects and timer once level failed or success : extra check
local function removingObjects()
  --print( "level 8 removingObjects" )
    if(timerObj ~= nil) then
      --print( "level 8 tiemrObj");
      timer.cancel( timerObj );
      --timerObj:removeSelf( );
      timerObj=nil;
    end
    if(timerObj2 ~= nil) then
      --print( "level 8 tiemrObj2");
      timer.cancel( timerObj2 );
      --timerObj2:removeSelf( );
      timerObj2=nil;
    end
  for i=1,indexTotal do
      if (allObjects[i] ~= nil ) then
          --print( "level8  removing i = "..i );
          allObjects[i][objID]:removeSelf( );
          allObjects[i][objID]=nil;
          allObjects[i]=nil;
      end
    end 
end

-- Call next level 
local function nextLevel(event)
 composer.gotoScene(event.target.level, sceneTransitionOptions);
end

-- Successfully level complete 
local function levelCompleted()
  if(statusFlag == 0) then
     statusFlag = 1;  -- used this flag into timer 2 
     sceneTransitionOptions.params.levelStatus[8] = "completed"; 
     sceneTransitionOptions.effect = "fromRight"; --sceneTransitionOptions.time = 0;
     
     message.text="Success!";
     continueImage.isVisible=true;
     removingObjects();
     continueImage:addEventListener( "tap", nextLevel );
  end
end

---level not complete 'Failed' 
local function levelFailed()
  if(statusFlag == 0) then
   statusFlag = 1;  -- used this flag into timer 2 
   sceneTransitionOptions.params.levelStatus[8] = "attempted"; 
   sceneTransitionOptions.effect = "flip"; sceneTransitionOptions.time = 0;
   message.text="Failed!";

   tryAgainImage.isVisible=true;
   removingObjects();
   tryAgainImage:addEventListener("tap", nextLevel); -- add tap event listener to "try again" image to retry this level
  end
end

-- Level select listener
local function levelSelect()
 removingObjects();
 sceneTransitionOptions.effect = "fade"; sceneTransitionOptions.time = 400;
 composer.gotoScene("levelscreen", sceneTransitionOptions);
end

-- check objects pstion on screen and remove them if out of the screen
function checkObjectPostions(  )
  for i=1,indexTotal do
    if(allObjects[i]~=nil and((allObjects[i][objID].x < ((allObjects[i][objID].width*-1)-10)  or allObjects[i][objID].x > display.contentWidth ) or
      (allObjects[i][objID].y < -10 or allObjects[i][objID].y > display.contentHeight )))then
      
      if (allObjects[i][objID].tag == "green") then
        nonRemObjCount=nonRemObjCount-1;
        --break;
      elseif(allObjects[i][objID].tag == "red" or allObjects[i][objID].tag == "blue") then
        remObjCount=remObjCount-1;
      end

      allObjects[i][objID]:removeSelf( );
      allObjects[i][objID]=nil;
      allObjects[i]=nil;
      
    end
  end
end

-- check the level status In each level check status function is different based on layout
function checkStatus()
  --print( "level8 checkStatus" )
  checkObjectPostions(); -- call it and update remain obj counter
  
  -- timer already exist, then cancle it
  if(tiemrObj2 ~= nil) then
    timer.cancel( tiemrObj2 )
    tiemrObj2=nil;
  end  

  -- Start the internal timer 
  if( remObjCount== 0 and tiemrObj2 == nil and statusFlag == 0) then
    local i =0;      
       timerObj2 =timer.performWithDelay( 1000, function()
                                  if( nonRemObjCount== 0 ) then
                                    i=3;
                                    levelFailed();

                                  end
                                  if( i == 2 and timerObj ~= nil) then  
                                    levelCompleted();
                                  end
                                  i=i+1;
                                  checkObjectPostions();
                                end ,3) ;
  end
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
   local previousScene;

   if phase == "will" then 
    for i = 1, 9 do  -- update level status based on passed value by previous screen
     sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
    end
    previousScene = composer.getSceneName("previous"); -- grab a reference to the previous scene
    if previousScene == "dummy" then -- if the previous scene was the dummy scene remove it
     composer.removeScene(previousScene);
    end
   --- PUT CODE HERE -------------------------------------------------------------------------------

   elseif phase == "did" then
      -- Create message object for status   
     message = display.newText("", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
     message:setFillColor(0, 0, 0);
     sceneGroup:insert( message);
      
      -- create try again object and set is invisible
     tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
     tryAgainImage.level = "dummy";
     tryAgainImage:scale(1.5, 1.5);
     tryAgainImage.isVisible=false;
     sceneGroup:insert( tryAgainImage);

     -- create continue object and set it invisible
     continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
     continueImage.level = "level9";
     continueImage:scale(1.9, 1.9);
     continueImage.isVisible=false;
     sceneGroup:insert( continueImage);

     -- create level select object
     levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
     levelSelectImage:scale(1.6, 1.6);
     levelSelectImage:addEventListener("tap", levelSelect);
    -------------------------
    -- reset all objects
      allObjects={};
      indexTotal=0;
      timerObj=nil;
      timerObj2=nil;
      remObjCount=3; -- all red boxes and platform
      nonRemObjCount=1; -- all green boxes or blue boxes for condition check
      statusFlag=0;
      staticCollisionFlag=0;

   --- PUT CODE HERE - RAKESH ------------------------------------------------------------------------------
    local xPos=100
    local yPos=300;
    physics.setGravity( 0, 0 );
    -- Start to create boxes

    -- 1 green long box 1
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,6,xPos,yPos )
     updateValues("greenLongBox1", 5, 2, 0, 1, 0,1,{indexTotal+2,0,0})
     allObjects[indexTotal][objID].tag="green";
     physics.addBody( allObjects[indexTotal][objID], "dynamic");
     allObjects[indexTotal][objID].isSensor=false;
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 2 blue long box 1
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,8,
        allObjects[1][objID].x,yPos+(allObjects[1][newWidth]) )
     updateValues("blueLongBox1", 2.55, 4, 1, 0, 0,1,{indexTotal-1,-10,30})
     allObjects[indexTotal][objID].tag="blue";
     -- special box thats why doing it here
     physics.addBody( allObjects[indexTotal][objID], "kinematic",{ isSensor = true } )
     allObjects[indexTotal][objID].bodyType = "kinematic"

     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 3 green pat box 1
     --print( allObjects[indexTotal][newHeight] .. allObjects[indexTotal][newWidth]  )
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,11,
        allObjects[2][objID].x,allObjects[2][objID].y+(allObjects[2][newWidth]/2)+25 )
     updateValues("greenPlat1", 1, 2, 0, 0, 0,0,nil)
     allObjects[indexTotal][objID].tag="green";
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 4 blue pat box 1
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,16,
        display.contentWidth-250,allObjects[2][objID].y+25 )
     updateValues("bluePlat1", 3, 2, 1, 0, 0,1,{indexTotal+1,-50,0})
     allObjects[indexTotal][objID].tag="blue";
     sceneGroup:insert( allObjects[indexTotal][objID] )
     --print( allObjects[indexTotal][newHeight] .. " - "..allObjects[indexTotal][newWidth]  )

     -- 5 red box 1
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,2,
        allObjects[indexTotal-1][objID].x+(allObjects[indexTotal-1][newHeight]*1.5),
        allObjects[indexTotal-1][objID].y );
     updateValues("redBox1", 3, 2, 0, 1, 1,1,nil);
     allObjects[indexTotal][objID].tag="red";
     sceneGroup:insert( allObjects[indexTotal][objID] )
     --print( allObjects[indexTotal][newHeight] .. " - "..allObjects[indexTotal][newWidth]  )

   end

end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 -- remove all objects and timer 
   if phase == "will" then
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

    if levelSelectImage ~= nil then
       levelSelectImage:removeSelf();
       levelSelectImage = nil;
    end

    -- remove all created object
    for i=1,indexTotal do
      if (allObjects[i] ~= nil ) then
        
        allObjects[i][objID]:removeSelf( );
        allObjects[i][objID]=nil;
        allObjects[i]=nil;
      end
      --print(i)
    end
    if(timerObj ~= nil) then
      
      timer.cancel( timerObj );
      --timerObj:removeSelf( );
      timerObj=nil;
    end
    if(timerObj2 ~= nil) then
      
      timer.cancel( timerObj2 );
      --timerObj2:removeSelf( );
      timerObj2=nil;
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
