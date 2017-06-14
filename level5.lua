-- Author: Rakesh
-- CS 571 Final Project  Level 5 for Red Remover Game 
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
composer.recycleOnSceneChange = true;
--composer.removeScene( "level5", true )
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
-- BOTH TIMER 
local timerObj=nil; 
local timerobj2=nil;
---- used this flag into timer 2 update it into level failed or level complete method
local statusFlag = 0;  -- used this flag into timer 2  updated into levelFailed or levelComplete methods


--{objID=nil,name="greenBox",removeable=0,motion=0,mandatory=0,newWidth=0,newHeight=0, affactedobj}
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


local checkStatus; -- function declaration

local remObjCount=4; -- all red boxes and platform
local nonRemObjCount=4; -- all green boxes or blue boxes for condition check

-- init the object value for each image obj
local function initObj( )

  allObjects[indexTotal][objID]=nil;
  allObjects[indexTotal][name]="default";
  allObjects[indexTotal][removeable]=1;
  allObjects[indexTotal][motion]=0;
  allObjects[indexTotal][mandatory]=0;
  allObjects[indexTotal][newWidth]=0;
  allObjects[indexTotal][newHeight]=0;
  allObjects[indexTotal][rotationFlag]=0;
  allObjects[indexTotal][affectedObject]=nil;

end
-- Collision Listener
local function collisionListener(event)
  
    local vx,vy;
    
    local tempObjGreen=nil;
    local tempObjTarget=nil;
    if (event.other.tag == "redG") then
      tempObjGreen = event.other; 
      tempObjTarget = event.target  
    else
        tempObjGreen = event.target
        tempObjTarget = event.other 
    end

    if (event.other.bodyType == "dynamic") then
      
      for i=1,indexTotal do
        if( allObjects[i] ~= nil and tempObjTarget == allObjects[i][objID] and allObjects[i][affectedObject] ~= nil) then
          
          vx=allObjects[i][affectedObject][2]*5;
          vy=allObjects[i][affectedObject][3]*5;
        end  
      end
      
      tempObjTarget:setLinearVelocity( vx, vy );
      tempObjGreen:setLinearVelocity( vx, vy );
      --event.target.isSensor=true;
      --event.other.isSensor=true;
      -- if (tempObjGreen.tag == "redG") then
      --   print( "other is green" );
      -- else
      --   print( "other is not green" );
      -- end

    end
    if (event.other.bodyType == "static") then
      
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
      for i=1,indexTotal do 
        if (allObjects[i] ~= nil and event.target == allObjects[i][objID] and allObjects[i][removeable] == 1) then
          if (allObjects[i][affectedObject] ~= nil ) then
            --print( "enter mFlag" )
              mFlag= allObjects[i][affectedObject][1]
              xF=allObjects[i][affectedObject][2]
              yF=allObjects[i][affectedObject][3]
            --print( mFlag .. " - "..xF .. " - ".. yF .. " - " )
          end
          if(event.target.tag == 'blue') then
            nonRemObjCount=nonRemObjCount-1;
          end
          allObjects[i][objID]:removeSelf( );
          allObjects[i][objID]=nil;
          allObjects[i]=nil;
            
          break;
        end
      end
    end

    if(mFlag ~= 0) then
      if(allObjects[mFlag][objID] ~= nil and allObjects[mFlag][motion] == 1) then
            physics.addBody( allObjects[mFlag][objID], "dynamic");
            allObjects[mFlag][objID]:addEventListener("collision",collisionListener)
         if (allObjects[mFlag][affectedObject] ~= nil) then
            physics.addBody( allObjects[allObjects[mFlag][affectedObject][1]][objID], "static");
         else  -- set our self velocity for collision
            if(xF  == 0)then
              xf=yF/2;
            elseif(yF  == 0)then
              yf=xF/2;
            end
            allObjects[mFlag][affectedObject]={mFlag,xF,yF};
         end       
         
        allObjects[mFlag][objID]:applyForce( xF, yF,allObjects[mFlag][objID].x,allObjects[mFlag][objID].y )
      end
    end  
  -- timer for checking level success of failed
  if(timerObj == nil and (nonRemObjCount == 0  ) and statusFlag == 0) then
    local i =0;
    
    timerObj=timer.performWithDelay( 1000, function(  )
                                            if(i>0) then 
                                              checkStatus();
                                            else
                                              i=i+1;
                                            end
                                    end 
                                    ,2);
  end

end

-- Update the object value after creation of the object
local function updateValues(nameT, xScale, yScale, remFlag, motionFlag, manFlag,rotFlag, affObj)

  local tempObj=allObjects[indexTotal];

  tempObj[newWidth]=tempObj[objID].width*xScale;
  tempObj[newHeight]=tempObj[objID].height*yScale;
  tempObj[rotationFlag]=rotFlag;

  if (rotFlag == 1) then
    tempObj[objID].width=tempObj[newHeight]
    tempObj[objID].height=tempObj[newWidth];
  else
    tempObj[objID].width=tempObj[newWidth]
    tempObj[objID].height=tempObj[newHeight];
  end  

  tempObj[name]=nameT;
  tempObj[removeable]=remFlag;
  tempObj[motion]=motionFlag;
  tempObj[mandatory]=manFlag;
  tempObj[affectedObject]=affObj;
  
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

local function removingObjects()

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
  for i=1,indexTotal do
      if (allObjects[i] ~= nil ) then
         
          allObjects[i][objID]:removeSelf( );
          allObjects[i][objID]=nil;
          allObjects[i]=nil;
      end
    end 
end

local function nextLevel(event)

 composer.gotoScene(event.target.level, sceneTransitionOptions);

end


local function levelCompleted()

if(statusFlag == 0 and message ~= nil) then
 statusFlag = 1;  -- used this flag into timer 2    
 sceneTransitionOptions.params.levelStatus[5] = "completed"; 
 sceneTransitionOptions.effect = "fromRight";sceneTransitionOptions.time = 0;
 
 message.text="Success!";
 continueImage.isVisible=true;
 removingObjects();
 continueImage:addEventListener( "tap", nextLevel );
end
end


local function levelFailed()
if(statusFlag == 0 and message ~= nil) then
 statusFlag = 1;  -- used this flag into timer 2 
 sceneTransitionOptions.params.levelStatus[5] = "attempted"; 
 sceneTransitionOptions.effect = "flip"; sceneTransitionOptions.time = 0;

 message.text="Failed!";
 tryAgainImage.isVisible=true;
 removingObjects();
 tryAgainImage:addEventListener("tap", nextLevel); -- add tap event listener to "try again" image to retry this level
end
end

-- level select listener
local function levelSelect()
 removingObjects();
 sceneTransitionOptions.effect = "fade"; sceneTransitionOptions.time = 400;
 composer.gotoScene("levelscreen", sceneTransitionOptions);
end

-- check objects pstion on screen and remove them if thay out of the screen and update counter
function checkObjectPostions(  )
  for i=1,indexTotal do
    if(allObjects[i]~=nil and((allObjects[i][objID].x < 0 or allObjects[i][objID].x > display.contentWidth ) or
      (allObjects[i][objID].y < 0 or allObjects[i][objID].y > display.contentHeight )))then
      allObjects[i][objID]:removeSelf( );
      allObjects[i][objID]=nil;
      allObjects[i]=nil;
      remObjCount = remObjCount -1;
    end
  end
end

-- check the level status Failed or Success
function checkStatus()
  --print( "level 5 checkStatus" )
  checkObjectPostions();
  -- timer 2 exist already then cancle it before begin
  if(tiemrObj2 ~= nil) then
    timer.cancel( tiemrObj2 )
    tiemrObj2=nil;
  end  
  if( nonRemObjCount== 0 and tiemrObj2 == nil and statusFlag == 0) then
    local i =0;  
                               
    timerobj2= timer.performWithDelay( 2000, function()
                                  if( remObjCount== 0 or i == 2) then
                                    i=2;
                                    levelCompleted();
                                  
                                  elseif( remObjCount ~= 0 and i == 1 ) then  
                                    levelFailed();
                                  end
                                  checkObjectPostions();
                                  i=i+1;
                                end ,2) ;
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
    for i = 1, 9 do
     sceneTransitionOptions.params.levelStatus[i] = event.params.levelStatus[i];
    end
    previousScene = composer.getSceneName("previous"); -- grab a reference to the previous scene
    if previousScene == "dummy" then -- if the previous scene was the dummy scene remove it    
     composer.removeScene(previousScene);
    end
   --- PUT CODE HERE -------------------------------------------------------------------------------

   elseif phase == "did" then
    --- Rakesh Code here  ---- 
if (indexTotal < 10) then
     
    -- Create message object for status   
     message = display.newText(" ", display.contentCenterX, display.contentHeight - 40, system.nativeFont, 42);
     message:setFillColor(0, 0, 0);
     sceneGroup:insert(message);
     -- create try again object and set is invisible
     tryAgainImage = display.newImage("tryAgain.png", display.contentWidth - 105, display.contentHeight - 45); 
     tryAgainImage.level = "dummy";
     tryAgainImage:scale(1.5, 1.5);
     tryAgainImage.isVisible=false;
     sceneGroup:insert(tryAgainImage);

    -- create continue object and set it invisible
     continueImage = display.newImage("continue.png", display.contentWidth - 110, display.contentHeight - 42); 
     continueImage.level = "level6";
     continueImage:scale(1.9, 1.9);
     continueImage.isVisible=false;
     sceneGroup:insert(continueImage);

     -- create level select object
     levelSelectImage = display.newImage("levelSelect.png", 102, display.contentHeight - 40);
     levelSelectImage:scale(1.6, 1.6);
     levelSelectImage:addEventListener("tap", levelSelect);
     sceneGroup:insert(levelSelectImage);

         -- add to screen group
     sceneGroup:insert(continueImage);
     sceneGroup:insert(tryAgainImage);
     sceneGroup:insert(message);
     sceneGroup:insert(levelSelectImage);

     ---------RESET all objects----------------
      allObjects={};
      indexTotal=0;
      timerObj=nil;
      timerObj2=nil;
      remObjCount=4; -- all red boxes and platform
      nonRemObjCount=4; -- all green boxes or blue boxes for condition check
      statusFlag=0;
  
     --- PUT CODE HERE RAKESH-------------------------------------------------------------------------------
     local xPos=display.contentCenterX
     local yPos=display.contentCenterY;
     physics.setGravity( 0, 0 );

     -- Start to create boxes
     callInit();
     -- 1 green box 1

     allObjects[indexTotal][objID]=display.newImage( imageSheet,3,xPos,yPos )
     updateValues("greenCenter", 2, 2, 0, 0, 0,0,nil)
     allObjects[indexTotal][objID].tag="green";
     sceneGroup:insert( allObjects[indexTotal][objID] )
     -- 2 red box 1 top
     callInit();
     allObjects[indexTotal][objID]=display.newImage( imageSheet,2,xPos,100 )
     updateValues("redTop", 2, 2, 0, 1,1,0,nil)
     allObjects[indexTotal][objID].tag="redG";
     sceneGroup:insert( allObjects[indexTotal][objID] )
     -- 3 red box 2  bottom
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,2,xPos,display.contentHeight-100 )
     updateValues("redBottom", 2, 2, 0, 1, 1, 0, nil)
     allObjects[indexTotal][objID].tag="redG";
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 4 red box 3 left
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,2,50,yPos+allObjects[1][newWidth]+20 )
     updateValues("redLeft", 2, 2, 0, 1, 1, 0, nil)
     allObjects[indexTotal][objID].tag="red";
     sceneGroup:insert( allObjects[indexTotal][objID] )


     -- 5 red box 4 right
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,2,display.contentWidth-50,yPos-allObjects[1][newWidth]-20 )
     updateValues("redRight", 2, 2, 0, 1, 1,0 ,nil)
     allObjects[indexTotal][objID].tag="red";
     sceneGroup:insert( allObjects[indexTotal][objID] )
     --print( allObjects[indexTotal][newHeight] .. " --- " )
     --- Blue Boxes

     -- 6 blue box 1 top
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,17,
                  allObjects[2][objID].x, allObjects[2][objID].y+(allObjects[2][newHeight]/2) )
     updateValues("blueTop", 4, 1, 1,0,0,0,{2,0,30})
     allObjects[indexTotal][objID].tag="blue";
   
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 7 blue box 2 bottom
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,17,
                  allObjects[3][objID].x, allObjects[3][objID].y-(allObjects[3][newHeight])/2)
     updateValues("blueBottom", 4, 1, 1,0,0,0,{3,0,-30})
     allObjects[indexTotal][objID].tag="blue";
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 8 blue box 3 left
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,17,
                  allObjects[4][objID].x+(allObjects[4][newHeight]/2), allObjects[4][objID].y)
     updateValues("blueLeft", 1, 4, 1,0,0,0,{4,40,0})
     allObjects[indexTotal][objID].tag="blue";
     sceneGroup:insert( allObjects[indexTotal][objID] )

     -- 9 blue box 4 right
     callInit();

     allObjects[indexTotal][objID]=display.newImage( imageSheet,17,
                  allObjects[5][objID].x-(allObjects[5][newHeight]/2), allObjects[5][objID].y)
     updateValues("blueRight", 1, 4, 1,0,0,0,{5,-40,0})
     allObjects[indexTotal][objID].tag="blue";
     sceneGroup:insert( allObjects[indexTotal][objID] )
   end -- indexTota check

   end
end

---- Remove the display objects if this scene is about to go away
function scene:hide(event)
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if (phase == "will") then
    if (continueImage ~= nil) then
       continueImage:removeSelf();
       continueImage = nil;
    end

    if (tryAgainImage ~= nil) then
       tryAgainImage:removeSelf();
       tryAgainImage = nil;
    end
    
    if (message ~= nil) then
       message:removeSelf();
       message = nil;
    end

    if (levelSelectImage ~= nil) then
       levelSelectImage:removeSelf();
       levelSelectImage = nil;
    end
    for i=1,indexTotal do
      if (allObjects[i] ~= nil ) then
          
          allObjects[i][objID]:removeSelf( );
          allObjects[i][objID]=nil;
          allObjects[i]=nil;
      end
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
     -- remove all created object
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