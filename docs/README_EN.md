# Tower Strategy Game

A mobile strategy game with roguelike elements, created in Godot 4.

## 🌐 Languages

- 🇺🇦 [Українська](../README_UA.md) - Повна документація українською мовою
- 🇬🇧 [English](../README_EN.md) - Complete documentation in English

## 🎮 Description

Tower Strategy is a game where the player controls a party of heroes, explores dungeons, collects treasures, and develops their city. The game is optimized for mobile devices with a 9:16 aspect ratio.

## ✨ Features

### 🏰 City Interface
- **Pixel-art design** with bright contrasting colors
- **Three main zones**:
  - 🏛️ **Dungeon Tower** - launch expeditions into dungeons
  - 🔮 **Hero Portal** - summon new heroes
  - 🏠 **Hero Mansion** - manage party and equipment

### 🗺️ Dungeon System
- **Procedural generation** of dungeon maps
- **Various cell types**:
  - Walls (impassable)
  - Floor (passable)
  - Enemies (red cells)
  - Treasures (yellow cells)
  - Exit (green cell)
- **Controls**: WASD or arrow keys
- **Combat system** (basic implementation)

### 📱 Mobile Optimization
- 9:16 aspect ratio
- Buttons minimum 80x80px size
- Visual feedback on press
- Vibration on mobile devices

## 🚀 Installation and Launch

### Requirements
- Godot 4.0 or higher
- Mobile platform support (Android/iOS)

### Launch
1. Clone the repository:
```bash
git clone https://github.com/your-username/tower-strategy.git
cd tower-strategy
```

2. Open the project in Godot Engine

3. Press F5 or the "Play" button to launch

## 🎯 Controls

### In the city:
- **Clicking buttons** - navigate to corresponding sections
- **Tower** - launch dungeon

### In the dungeon:
- **WASD** or **arrow keys** - move player
- **ESC** - return to city
- **Back button** - return to city

## 📁 Project Structure

```
towerstrategy/
├── Main.tscn                 # Main scene
├── MainMap.gd               # World map logic
├── CityUI.tscn              # City interface
├── CityUI.gd                # City UI logic
├── CityUIButton.gd          # City UI buttons
├── DungeonManager.gd        # Dungeon manager
├── DungeonScene.tscn        # Dungeon scene
├── DungeonScene.gd          # Dungeon logic
├── Hero.gd                  # Hero system
├── Party.gd                 # Party management
├── TeamManager.gd           # Team manager
├── assets/                  # Game resources
│   └── sprites/            # Sprites
├── README.md               # Documentation
└── .gitignore              # Git ignore
```

## 🎨 Technical Details

### Color Scheme
- **City background**: #6688CC (blue)
- **UI panels**: #1A1A33 (dark blue, 90% transparency)
- **Tower**: #FF9933 (orange)
- **Portal**: #CC66FF (purple)
- **Mansion**: #33CC66 (green)

### Sizes
- **Base resolution**: 360x640px (9:16)
- **Minimum button size**: 80x80px
- **Dungeon cell size**: 32x32px

## 🔧 Development

### Adding New Features
1. Create a new scene or script
2. Add logic to the corresponding manager
3. Update UI if necessary
4. Test on mobile devices

### Signal System
- `dungeon_run_requested` - request to launch dungeon
- `hero_portal_opened` - opening hero portal
- `hero_mansion_opened` - opening hero mansion
- `dungeon_completed` - dungeon completion

## 📝 Development Plans

- [ ] Combat system with enemies
- [ ] Inventory and equipment
- [ ] Hero leveling system
- [ ] More dungeon types
- [ ] Achievement system
- [ ] Progress saving
- [ ] Sound effects and music

## 🤝 Contributing

1. Fork the repository
2. Create a branch for a new feature
3. Make changes
4. Create a Pull Request

## 📄 License

This project is distributed under the MIT license. See the LICENSE file for details.

## 👨‍💻 Author

Created with Godot Engine and love for games! 🎮

---

**Version**: 1.0.0  
**Last update**: 2024