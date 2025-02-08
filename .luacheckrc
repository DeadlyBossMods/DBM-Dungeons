std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc"
}
ignore = {
	"1..", -- Everything related to globals, the LuaLS check is better
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	"231/_.*", -- unused variables starting with _
	"311", -- Value assigned to a local variable is unused
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
}
