# Roblox UI Library for Executors

A modern, feature-rich UI library for Roblox executors with dark/light theme support.

## Features
- 🎨 Dark/Light theme support
- 📦 Components: Buttons, Toggles, Checkboxes, TextBoxes, Sliders, Dropdowns
- ✨ Smooth animations
- 🎯 Easy to use API
- 🪟 Draggable windows
- 🔌 Event system

## Installation

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/UILibrary.lua"))()
```

# Components

## Button

```lua
UILibrary:Create(parent, "Button", {
    Text = "Click Me",
    Size = UDim2.new(0, 200, 0, 40),
    Position = UDim2.new(0.5, -100, 0, 20),
})
```

