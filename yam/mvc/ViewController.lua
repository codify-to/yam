require 'yam.middleclass'
local storyboard = require "storyboard"

ViewController = class('ViewController') 

function ViewController:init(event) end
function ViewController:show(event) end
function ViewController:resize(event) end
function ViewController:hide(event) end
function ViewController:dispose(event) end

function ViewController:initialize()
  local scene = storyboard.newScene()
  local this = self

  function scene:createScene( event )
      this.view = scene.view
      this:init(event)
  end 

  function scene:willEnterScene( event )
      this:resize(event)
  end 
  function scene:enterScene( event )
      this:show(event)
  end
  function scene:exitScene( event )
      this:hide(event);
  end
  function scene:destroyScene( event )
      this:dispose(event)
  end
  function onOrientationChange( event )
      this:resize(event);
  end
   
  scene:addEventListener( "createScene", scene )
  scene:addEventListener( "willEnterScene", scene )
  scene:addEventListener( "enterScene", scene )
  scene:addEventListener( "exitScene", scene )
  scene:addEventListener( "destroyScene", scene )
  Runtime:addEventListener( "orientation", onOrientationChange )

  self.scene = scene
  self.params = storyboard.params
end
