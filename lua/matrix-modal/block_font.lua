-- Embedded 5x7 bitmap font for matrix-modal's block-text rendering.
--
-- No external dependencies: each printable ASCII glyph (0x20-0x7E) is authored
-- inline as seven rows of five cells using '#' (on) and '.' (off). M.render()
-- expands a message into a multi-line string of on/off characters that flows
-- straight through matrix-modal's existing build_target()/decrypt pipeline.
local M = {}

M.GLYPH_W = 5 -- cells wide per glyph
M.GLYPH_H = 7 -- cells tall per glyph
M.GAP = 1 -- blank cells between adjacent glyphs

-- Splits a string into single-codepoint pieces (UTF-8 safe).
local function split_chars(s)
  return vim.fn.split(s, "\\zs")
end

-- Authored glyphs. The leading newline after [[ is dropped by Lua, so each
-- value is exactly GLYPH_H rows of GLYPH_W characters.
local RAW = {
  [" "] = [[
.....
.....
.....
.....
.....
.....
.....]],
  ["!"] = [[
..#..
..#..
..#..
..#..
..#..
.....
..#..]],
  ['"'] = [[
.#.#.
.#.#.
.#.#.
.....
.....
.....
.....]],
  ["#"] = [[
.#.#.
.#.#.
#####
.#.#.
#####
.#.#.
.#.#.]],
  ["$"] = [[
..#..
.####
#.#..
.###.
..#.#
####.
..#..]],
  ["%"] = [[
##...
##..#
...#.
..#..
.#...
#..##
...##]],
  ["&"] = [[
.##..
#..#.
#.#..
.#...
#.#.#
#..#.
.##.#]],
  ["'"] = [[
..#..
..#..
..#..
.....
.....
.....
.....]],
  ["("] = [[
...#.
..#..
.#...
.#...
.#...
..#..
...#.]],
  [")"] = [[
.#...
..#..
...#.
...#.
...#.
..#..
.#...]],
  ["*"] = [[
.....
..#..
#.#.#
.###.
#.#.#
..#..
.....]],
  ["+"] = [[
.....
..#..
..#..
#####
..#..
..#..
.....]],
  [","] = [[
.....
.....
.....
.....
..#..
..#..
.#...]],
  ["-"] = [[
.....
.....
.....
#####
.....
.....
.....]],
  ["."] = [[
.....
.....
.....
.....
.....
.##..
.##..]],
  ["/"] = [[
....#
....#
...#.
..#..
.#...
#....
#....]],
  ["0"] = [[
.###.
#...#
#..##
#.#.#
##..#
#...#
.###.]],
  ["1"] = [[
..#..
.##..
..#..
..#..
..#..
..#..
.###.]],
  ["2"] = [[
.###.
#...#
....#
...#.
..#..
.#...
#####]],
  ["3"] = [[
#####
...#.
..#..
...#.
....#
#...#
.###.]],
  ["4"] = [[
...#.
..##.
.#.#.
#..#.
#####
...#.
...#.]],
  ["5"] = [[
#####
#....
####.
....#
....#
#...#
.###.]],
  ["6"] = [[
..##.
.#...
#....
####.
#...#
#...#
.###.]],
  ["7"] = [[
#####
....#
...#.
..#..
.#...
.#...
.#...]],
  ["8"] = [[
.###.
#...#
#...#
.###.
#...#
#...#
.###.]],
  ["9"] = [[
.###.
#...#
#...#
.####
....#
...#.
.##..]],
  [":"] = [[
.....
.##..
.##..
.....
.##..
.##..
.....]],
  [";"] = [[
.....
.##..
.##..
.....
.##..
..#..
.#...]],
  ["<"] = [[
...#.
..#..
.#...
#....
.#...
..#..
...#.]],
  ["="] = [[
.....
.....
#####
.....
#####
.....
.....]],
  [">"] = [[
.#...
..#..
...#.
....#
...#.
..#..
.#...]],
  ["?"] = [[
.###.
#...#
....#
...#.
..#..
.....
..#..]],
  ["@"] = [[
.###.
#...#
....#
.##.#
#.#.#
#.#.#
.####]],
  ["A"] = [[
.###.
#...#
#...#
#####
#...#
#...#
#...#]],
  ["B"] = [[
####.
#...#
#...#
####.
#...#
#...#
####.]],
  ["C"] = [[
.###.
#...#
#....
#....
#....
#...#
.###.]],
  ["D"] = [[
###..
#..#.
#...#
#...#
#...#
#..#.
###..]],
  ["E"] = [[
#####
#....
#....
####.
#....
#....
#####]],
  ["F"] = [[
#####
#....
#....
####.
#....
#....
#....]],
  ["G"] = [[
.###.
#...#
#....
#.###
#...#
#...#
.###.]],
  ["H"] = [[
#...#
#...#
#...#
#####
#...#
#...#
#...#]],
  ["I"] = [[
.###.
..#..
..#..
..#..
..#..
..#..
.###.]],
  ["J"] = [[
..###
...#.
...#.
...#.
...#.
#..#.
.##..]],
  ["K"] = [[
#...#
#..#.
#.#..
##...
#.#..
#..#.
#...#]],
  ["L"] = [[
#....
#....
#....
#....
#....
#....
#####]],
  ["M"] = [[
#...#
##.##
#.#.#
#.#.#
#...#
#...#
#...#]],
  ["N"] = [[
#...#
##..#
#.#.#
#.#.#
#..##
#...#
#...#]],
  ["O"] = [[
.###.
#...#
#...#
#...#
#...#
#...#
.###.]],
  ["P"] = [[
####.
#...#
#...#
####.
#....
#....
#....]],
  ["Q"] = [[
.###.
#...#
#...#
#...#
#.#.#
#..#.
.##.#]],
  ["R"] = [[
####.
#...#
#...#
####.
#.#..
#..#.
#...#]],
  ["S"] = [[
.###.
#...#
#....
.###.
....#
#...#
.###.]],
  ["T"] = [[
#####
..#..
..#..
..#..
..#..
..#..
..#..]],
  ["U"] = [[
#...#
#...#
#...#
#...#
#...#
#...#
.###.]],
  ["V"] = [[
#...#
#...#
#...#
#...#
#...#
.#.#.
..#..]],
  ["W"] = [[
#...#
#...#
#...#
#.#.#
#.#.#
##.##
#...#]],
  ["X"] = [[
#...#
#...#
.#.#.
..#..
.#.#.
#...#
#...#]],
  ["Y"] = [[
#...#
#...#
.#.#.
..#..
..#..
..#..
..#..]],
  ["Z"] = [[
#####
....#
...#.
..#..
.#...
#....
#####]],
  ["["] = [[
.###.
.#...
.#...
.#...
.#...
.#...
.###.]],
  ["\\"] = [[
#....
#....
.#...
..#..
...#.
....#
....#]],
  ["]"] = [[
.###.
...#.
...#.
...#.
...#.
...#.
.###.]],
  ["^"] = [[
..#..
.#.#.
#...#
.....
.....
.....
.....]],
  ["_"] = [[
.....
.....
.....
.....
.....
.....
#####]],
  ["`"] = [[
.#...
..#..
...#.
.....
.....
.....
.....]],
  ["a"] = [[
.....
.....
.###.
....#
.####
#...#
.####]],
  ["b"] = [[
#....
#....
####.
#...#
#...#
#...#
####.]],
  ["c"] = [[
.....
.....
.###.
#...#
#....
#...#
.###.]],
  ["d"] = [[
....#
....#
.####
#...#
#...#
#...#
.####]],
  ["e"] = [[
.....
.....
.###.
#...#
#####
#....
.###.]],
  ["f"] = [[
..##.
.#..#
.#...
###..
.#...
.#...
.#...]],
  ["g"] = [[
.....
.####
#...#
#...#
.####
....#
.###.]],
  ["h"] = [[
#....
#....
####.
#...#
#...#
#...#
#...#]],
  ["i"] = [[
..#..
.....
.##..
..#..
..#..
..#..
.###.]],
  ["j"] = [[
...#.
.....
...#.
...#.
...#.
#..#.
.##..]],
  ["k"] = [[
#....
#....
#..#.
#.#..
##...
#.#..
#..#.]],
  ["l"] = [[
.##..
..#..
..#..
..#..
..#..
..#..
.###.]],
  ["m"] = [[
.....
.....
##.#.
#.#.#
#.#.#
#...#
#...#]],
  ["n"] = [[
.....
.....
####.
#...#
#...#
#...#
#...#]],
  ["o"] = [[
.....
.....
.###.
#...#
#...#
#...#
.###.]],
  ["p"] = [[
.....
####.
#...#
#...#
####.
#....
#....]],
  ["q"] = [[
.....
.####
#...#
#...#
.####
....#
....#]],
  ["r"] = [[
.....
.....
#.##.
##..#
#....
#....
#....]],
  ["s"] = [[
.....
.....
.####
#....
.###.
....#
####.]],
  ["t"] = [[
.#...
.#...
###..
.#...
.#...
.#..#
..##.]],
  ["u"] = [[
.....
.....
#...#
#...#
#...#
#...#
.####]],
  ["v"] = [[
.....
.....
#...#
#...#
#...#
.#.#.
..#..]],
  ["w"] = [[
.....
.....
#...#
#...#
#.#.#
#.#.#
.#.#.]],
  ["x"] = [[
.....
.....
#...#
.#.#.
..#..
.#.#.
#...#]],
  ["y"] = [[
.....
#...#
#...#
#...#
.####
....#
.###.]],
  ["z"] = [[
.....
.....
#####
...#.
..#..
.#...
#####]],
  ["{"] = [[
...#.
..#..
..#..
.#...
..#..
..#..
...#.]],
  ["|"] = [[
..#..
..#..
..#..
..#..
..#..
..#..
..#..]],
  ["}"] = [[
.#...
..#..
..#..
...#.
..#..
..#..
.#...]],
  ["~"] = [[
.....
.....
.##.#
#.##.
.....
.....
.....]],
}

-- char -> { row1, ..., row7 } with each row a GLYPH_W-length '#'/'.' string.
M.glyphs = {}
for ch, pattern in pairs(RAW) do
  M.glyphs[ch] = vim.split(pattern, "\n", { plain = true })
end

-- Unknown / unrenderable characters fall back to a blank cell (the space glyph).
local MISSING = M.glyphs[" "]

-- Glyphs that fit on one block line at the given pixel width. n glyphs occupy
-- n*GLYPH_W + (n-1)*GAP cells, so the largest n with that <= width is
-- floor((width + GAP) / (GLYPH_W + GAP)). Always at least one.
local function capacity_for(width)
  return math.max(1, math.floor((width + M.GAP) / (M.GLYPH_W + M.GAP)))
end

-- Greedy word-wrap of a single source line to `capacity` glyphs per line. Words
-- longer than the capacity are hard-broken. Returns at least one (possibly
-- empty) line so a blank source line still produces a vertical gap.
local function wrap_line(line, capacity)
  local out = {}
  local cur = ""
  for _, word in ipairs(vim.split(line, " ", { plain = true })) do
    while #word > capacity do
      if cur ~= "" then
        out[#out + 1] = cur
        cur = ""
      end
      out[#out + 1] = word:sub(1, capacity)
      word = word:sub(capacity + 1)
    end
    local candidate = (cur == "") and word or (cur .. " " .. word)
    if #candidate <= capacity then
      cur = candidate
    else
      if cur ~= "" then
        out[#out + 1] = cur
      end
      cur = word
    end
  end
  if cur ~= "" then
    out[#out + 1] = cur
  end
  if #out == 0 then
    out = { "" }
  end
  return out
end

-- Renders one wrapped line into GLYPH_H output rows, appending them to `acc`.
local function render_wrapped_line(line, on, off, acc)
  local gap = string.rep(off, M.GAP)
  local rows = {}
  for r = 1, M.GLYPH_H do
    rows[r] = {}
  end
  local chars = split_chars(line)
  for ci, ch in ipairs(chars) do
    local g = M.glyphs[ch] or MISSING
    for r = 1, M.GLYPH_H do
      if ci > 1 then
        rows[r][#rows[r] + 1] = gap
      end
      rows[r][#rows[r] + 1] = (g[r]:gsub("[#.]", function(c)
        return c == "#" and on or off
      end))
    end
  end
  for r = 1, M.GLYPH_H do
    acc[#acc + 1] = table.concat(rows[r])
  end
end

-- Expands `text` into a multi-line string of `on`/`off` cells. Source newlines
-- and width-driven word-wrapping each start a new block line; block lines are
-- separated by one blank row. `on` defaults to a solid block, `off` to a space.
---@param text string
---@param width integer Target pixel width to wrap within (e.g. the grid width).
---@param on? string Character for lit cells (default "█").
---@param off? string Character for blank cells (default " ").
---@return string
function M.render(text, width, on, off)
  on = on or "█"
  off = off or " "
  local capacity = capacity_for(width)
  local acc = {}
  local first = true
  for _, source_line in ipairs(vim.split(text or "", "\n", { plain = true })) do
    for _, wrapped in ipairs(wrap_line(source_line, capacity)) do
      if not first then
        acc[#acc + 1] = "" -- blank separator row between block lines
      end
      first = false
      render_wrapped_line(wrapped, on, off, acc)
    end
  end
  return table.concat(acc, "\n")
end

return M
