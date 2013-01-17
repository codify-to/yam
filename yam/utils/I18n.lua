-------------------------------------------------
--
-- Based on: class_I18N.lua by Brill Pappin, Sixgreen Labs Inc. (http://developer.anscamobile.com/code/i18n-strings)
--
-- Provides locale specific strings, with more specific values overriding more general values.
--
-------------------------------------------------
require 'yam.middleclass'
local json = require("json")

I18n = class('I18n') 

function I18n:initialize(resource)  -- The constructor
    
    self.resource = resource or "data/locales/strings"
    self.language = system.getPreference("locale", "language") or system.getPreference("ui", "language")
    self.country = system.getPreference( "locale", "country" )
    
    
    self.files = {
            self.resource..".i18n",
            self.resource.."_"..self.language..".i18n",
            self.resource.."_"..self.language.."_"..self.country..".i18n"
        }
            
    -- Files are processed in order so that finer grained 
    -- message override ones that are more general.
    local strmap = {}
    for i = 1, #self.files do
        local path = system.pathForFile( self.files[i], system.ResourcesDirectory )

        if path then
            local file = io.open( path, "r" )
            if file then -- nil if no file found
                local contents = file:read( "*a" )
                io.close( file )
                
                local resmap = json.decode(contents)
                for key, value in pairs(resmap) do
                    strmap[key] = value;
                end
                    
            end
        end
    end
    self.strings = strmap
end

function I18n:getString(key)
        if self.strings[key] then 
            return self.strings[key]
        else
            return "{{"..key.."}}"
        end
end

function I18n:__tostring()
  return "I18N [resource="..self.resource..", language="..self.language..", country="..self.country.."]" 
end

function I18n:__call(key)
  return self:getString(key)
end