-----------------------------------------------------------
-- Setting global access to middleclass, underscore & i18n
-----------------------------------------------------------
require 'yam.middleclass'
_ = require 'yam.underscore'
require("yam.utils.I18n")
i18n = I18n:new()

------------------------------------------------------
-- Global Screen Dimensions
------------------------------------------------------
     centerX = display.contentCenterX
     centerY = display.contentCenterY
     screenX = display.screenOriginX
     screenY = display.screenOriginY
 screenWidth = display.contentWidth - screenX * 2
screenHeight = display.contentHeight - screenY * 2
  screenLeft = screenX
 screenRight = screenX + screenWidth
   screenTop = screenY
screenBottom = screenY + screenHeight



local orm = require "yam.db.orm"
local storyboard = require "storyboard"

Yam = class('Yam')
function Yam:initialize(appName)
	self.appName = appName
 	print ("yam: Initializing " .. appName)
	-- Load add params
	local params = require "data.parameters"
	-- Custom user parameters
	pcall(function()
		local myConfig = require "data.myParameters"
		for k,v in pairs(myConfig) do
			params[k] = v
		end
	end)

	-- Initiate database
	print ("yam: Initializing database")
	_G.db = orm.initialize( system.pathForFile(appName .. ".db", system.DocumentsDirectory) )

	-- Start navigation
	storyboard.params = params
	storyboard.gotoScene(storyboard.params.firstView)
end