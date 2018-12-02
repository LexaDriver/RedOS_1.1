local component = require("component")
local gpu = component.gpu

gpu.set(12, 6, "╒════════════╧════════════╧╕")
gpu.set(12, 7, "│  There are equal objects │")
gpu.set(12, 8, "├╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤")
gpu.set(12, 9, "│  Take into consideration │")
gpu.set(12, 10, "└────────────┬────────────┬┘")

gpu.setBackground(0xffffff)
gpu.setForeground(0x000000)

gpu.set(13, 9, "  Take into consideration ")

gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)