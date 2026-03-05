require("git"):setup { order = 1500 }

-- Sort indicator in header (clickable)
local sort_labels = {
	alphabetical = "ABC",
	natural = "Nat",
	mtime = "Mod",
	btime = "Birth",
	size = "Size",
	extension = "Ext",
	random = "Rand",
}

local sort_cycle = { "natural", "mtime", "btime" }
local sort_positions = {}
local sort_indicator_width = 0

Header:children_add(function()
	local pref = cx.active.pref
	local current = tostring(pref.sort_by)
	local arrow = pref.sort_reverse and " ↑" or " ↓"
	local dir = pref.sort_dir_first and " D" or ""

	local spans = { ui.Span(" [") }
	local col = 2 -- after " ["
	sort_positions = {}
	for i, s in ipairs(sort_cycle) do
		local label = sort_labels[s] or s
		if i > 1 then
			spans[#spans + 1] = ui.Span(" ")
			col = col + 1
		end
		sort_positions[#sort_positions + 1] = { sort = s, from = col, to = col + #label - 1 }
		if s == current then
			spans[#spans + 1] = ui.Span(label):bold()
		else
			spans[#spans + 1] = ui.Span(label):dim()
		end
		col = col + #label
	end
	local suffix = arrow .. dir .. "] "
	spans[#spans + 1] = ui.Span(suffix)
	local line = ui.Line(spans)
	sort_indicator_width = line:width()

	return line
end, 2000, Header.RIGHT)

function Header:click(event, up)
	if up then return end

	if event.is_left then
		local comp_start = self._area.x + self._area.w - sort_indicator_width
		local rel_x = event.x - comp_start

		for _, pos in ipairs(sort_positions) do
			if rel_x >= pos.from and rel_x <= pos.to then
				if pos.sort == tostring(cx.active.pref.sort_by) then
					ya.emit("sort", { reverse = not cx.active.pref.sort_reverse })
				else
					ya.emit("sort", { pos.sort })
				end
				return
			end
		end
	elseif event.is_right then
		ya.emit("sort", { reverse = not cx.active.pref.sort_reverse })
	elseif event.is_middle then
		ya.emit("sort", { dir_first = not cx.active.pref.sort_dir_first })
	end
end
