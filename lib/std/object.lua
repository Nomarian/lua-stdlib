--- Prototype-based objects
-- <ul>
--   <li>Create an object/class:</li>
--   <ul>
--     <li>Either, if the <code>_init</code> field is a list:
--     <ul>
--       <li><code>object/Class = prototype {value, ...; field = value, ...}</code></li>
--       <li>Named values are assigned to the corresponding fields, and unnamed values
--       to the fields given by <code>_init</code>.</li>
--     </ul>
--     <li>Or, if the <code>_init</code> field is a function:
--     <ul>
--       <li><code>object/Class = prototype (value, ...)</code></li>
--       <li>The given values are passed as arguments to the <code>_init</code> function.</li>
--     </ul>
--     <li>An object's metatable is itself.</li>
--     <li>Private fields and methods start with "<code>_</code>".</li>
--   </ul>
--   <li>Access an object field: <code>object.field</code></li>
--   <li>Call an object method: <code>object:method (...)</code></li>
--   <li>Call a class method: <code>Class.method (object, ...)</code></li>
--   <li>Add a field: <code>object.field = x</code></li>
--   <li>Add a method: <code>function object:method (...) ... end</code></li>
-- </li>

local table = require "std.base"


--- Root object
-- @class functable
-- @name new
-- @field _init constructor method or list of fields to be initialised by the
-- constructor
-- @field _clone object constructor which provides the behaviour for <code>_init</code>
-- documented above
local new = {
  _type = "object",

  _init = {},

  _clone = function (self, ...)
    local object = table.clone (self)
    if type (self._init) == "table" then
      table.merge (object, table.clone_rename (self._init, ...))
    else
      object = self._init (object, ...)
    end
    return setmetatable (object, object)
  end,

  -- Sugar instance creation
  __call = function (...)
    -- First (...) gets first element of list
    return (...)._clone (...)
  end,
}
setmetatable (new, new)

local function typeof (object)
  if type (object) == "table" and rawget (object, "_type") ~= nil then
    return object._type
  end
  return type (object)
end

local M = {
  new    = new,
  typeof = typeof,
}

return setmetatable (M, {
  -- Sugar to call new automatically from module table.
  -- Use select to replace `self` (this table) with `new`, the real prototype.
  __call = function (...)
    return new._clone (new, select (2, ...))
  end,
})