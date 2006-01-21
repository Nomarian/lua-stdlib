-- Regular expressions

-- Default constructor (use PCREs)
setmetatable (rex, {__call =
                function (self, p, cf, lo)
                  return self.newPCRE (p, cf, lo)
                end})

-- @function rex.find: string.find for rex library
--   @param s: string to search
--   @param p: pattern to find
--   @param [cf]: compile-time flags for the regex
--   @param [lo]: locale for the regex
--   @param [ef]: execution flags for the regex
-- returns
--   @param from, to: start and end points of match, or nil
--   @param sub: table of substring matches, or nil if none
function rex.find (s, p, cf, lo, ef)
  return rex (p, cf, lo):match (s, 1, ef)
end

-- @function rex.gsub: string.gsub for rex
--   @param s: string to search
--   @param p: pattern to find
--   @param f: replacement function or string
--   @param [n]: maximum number of replacements [all]
--   @param [cf]: compile-time flags for the regex
--   @param [lo]: locale for the regex
--   @param [ef]: execution flags for the regex
-- returns
--   @param r: string with replacements
--   @param reps: number of replacements made
function rex.gsub (s, p, f, n, cf, lo, ef)
  local reg = rex (p, cf, lo)
  local st = 1
  local r, reps = {}, 0
  local from, to, sub
  if type (f) == "string" then
    local rep = f
    f = function (...)
          local ret = rep
          for i = 1, table.getn (arg) do
            ret = string.gsub (ret, "%%" .. tostring (i), arg[i])
          end
          return ret
        end
  end
  repeat
    from, to, sub = reg:match (s, st, ef)
    if from then
      table.insert (r, string.sub (s, st, from - 1))
      table.insert (r, f (unpack (sub)) or "")
      st = to + 1
      reps = reps + 1
      if n and reps == n then
        break
      end
    end
  until not from
  table.insert (r, string.sub (s, st))
  return table.concat (r), reps
end