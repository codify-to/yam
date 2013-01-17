-- Base class for SQLite aware model classes
-- Based on https://github.com/radamanthus/radlib
--
-- USAGE
--
-- Create a Lua file for your module. The file should look like this:
--
-- require 'Model'
-- Product = Model:subclass('Model')
-- Product.tableName = 'products'
-- Product.tableFields = {
--  id = {type = 'integer', flags = {'primary_key', 'autoincrement', 'not_null'} },
--  name = {type = 'string', flags = {'not_null'} }
-- }
--
-- If the table does not yet exist, you can create it in your app initialization with this call:
--
-- orm.initialize()
-- Product.createTable()
--
-- Sample API calls
--
-- local products = Product.findAll
--
-- p = Product.new{id = 1, name = 'test', description = ''} 
-- p.save
--
-- p.updateAttribute('name', 'newName')
-- p.updateAttributes{name = 'newName', description = 'newDescription'}
--
-- p = Product.find(1)
-- test_products = Product.where("name = 'test'")
--
-- numberOfProducts = Product.count()
--

require 'yam.middleclass'
local orm = require 'yam.db.orm'
local sql = require 'yam.db.sql'

Model = class('Model')

------------------------------------------------------------------------------
-- CLASS (STATIC) METHODS - START
------------------------------------------------------------------------------
function Model:initialize(newRecord)
  for k,v in pairs(newRecord) do
    self[k] = v
  end
end

------------------------------------------------------------------------------
-- Returns the number of rows in the table
------------------------------------------------------------------------------
function Model.static:count()
  return orm.getTableRowCount(self.tableName)
end

------------------------------------------------------------------------------
-- Creates the table
-- TODO: If options.recreate = true, it drops the table if it already exists
------------------------------------------------------------------------------
function Model.static:createTable(options)
  local createSql = sql.generateCreateTable(self.tableName, self.tableFields)
  db:exec( createSql )
end

------------------------------------------------------------------------------
-- Returns the record matching the given id. Returns nil if no match is found.
--
-- NOTE: Until I figure out how to determine the caller's class,
-- I'll have to resort to this ugliness of using the klass parameter
------------------------------------------------------------------------------
function Model.static:find(klass, id)
  local record = orm.selectOne(klass.tableName, 'id', id)
  if not( record == nil ) then
    result = klass:new(record)
  end
  return result
end

------------------------------------------------------------------------------
-- Returns all rows in the table that match the given filter
------------------------------------------------------------------------------
function Model.static:findAll( klass, params )
  local result = nil
  if params == nil then
    params = {}
  end
  if params.where == nil then
    result = orm.selectAll( klass.tableName, params )
  else
    result = orm.selectWhere( klass.tableName, params )
  end
  return result
end

------------------------------------------------------------------------------
-- Updates all rows in the table that match the given filter
------------------------------------------------------------------------------
function Model.static:updateAll( klass, updateSql, filter )
  if filter == nil then
    orm.updateAll( klass.tableName, updateSql )
  else
    orm.updateWhere( klass.tableName, updateSql, filter )
  end
end

------------------------------------------------------------------------------
-- CLASS (STATIC) METHODS - END
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- INSTANCE METHODS - START
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Reloads the record values from the database
------------------------------------------------------------------------------
function Model:reload()
  local updatedRecord = orm.selectOne( self.class.tableName, 'id', self.id )
  if updatedRecord ~= nil then
    for k,v in pairs(updatedRecord) do
      self[k] = v
    end
  end
end

------------------------------------------------------------------------------
-- Saves the content of the object to the database.
-- If a matching record already exists in the database, an UPDATE is done.
-- Otherwise an INSERT is done.
------------------------------------------------------------------------------
function Model:save()
  local updateTable = {}
  for k in pairs(self.class.tableFields) do
    updateTable[k] = self[k]
  end
  orm.createOrUpdate( self.class.tableName, updateTable )
end

------------------------------------------------------------------------------
-- Updates one column value
------------------------------------------------------------------------------
function Model:updateAttribute( columnName, columnValue )
  local filter = "id = " .. self.id
  orm.updateAttribute( self.class.tableName, filter, columnName, columnValue )
end

------------------------------------------------------------------------------
-- Updates an array of columns
------------------------------------------------------------------------------
function Model:updateAttributes( updateTable )
  local filter = "id = " .. self.id
  local columns = {}
  local columnValues = {}
  for k,v in pairs(updateTable) do
    table.insert( columns, k )
    table.insert( columnValues, v )
  end
  orm.updateAttributes( self.class.tableName, filter, columns, columnValues )
end

------------------------------------------------------------------------------
-- INSTANCE METHODS - END
------------------------------------------------------------------------------
