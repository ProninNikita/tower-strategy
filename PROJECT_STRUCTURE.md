# Tower Strategy - Project Structure

## 📁 Новая структура проекта

Проект был рефакторен для лучшей организации и поддержки кода. Вот новая структура папок:

```
towerstrategy/
├── 📁 scenes/                    # Все сцены Godot (.tscn файлы)
│   ├── Main.tscn
│   ├── CityUI.tscn
│   ├── DungeonScene.tscn
│   ├── BattleScene.tscn
│   ├── MainMap.tscn
│   ├── ExpeditionMap.tscn
│   ├── Party.tscn
│   ├── MapPoint.tscn
│   ├── Hero.tscn
│   └── PointMarker.tscn
│
├── 📁 scripts/                   # Все скрипты GDScript
│   ├── 📁 managers/              # Менеджеры системы
│   │   ├── DungeonManager.gd
│   │   ├── EventManager.gd
│   │   ├── TeamManager.gd
│   │   └── MapController.gd
│   │
│   ├── 📁 ui/                    # Пользовательский интерфейс
│   │   ├── CityUI.gd
│   │   ├── CityUIButton.gd
│   │   └── MapPointButton.gd
│   │
│   ├── 📁 gameplay/              # Игровая логика
│   │   ├── DungeonScene.gd
│   │   ├── MainMap.gd
│   │   ├── ExpeditionMap.gd
│   │   ├── MapGenerator.gd
│   │   ├── Hero.gd
│   │   ├── Party.gd
│   │   ├── MapPoint.gd
│   │   ├── MapNode.gd
│   │   ├── PointMarker.gd
│   │   └── BattleScene.gd
│   │
│   └── 📁 data/                  # Данные и константы
│       ├── map_constants.gd
│       └── map_point_data.gd
│
├── 📁 assets/                    # Ресурсы игры
│   ├── 📁 sprites/              # Спрайты и изображения
│   ├── 📁 audio/                # Звуки и музыка
│   ├── 📁 fonts/                # Шрифты
│   ├── icon.svg                 # Иконка проекта
│   └── icon.svg.import
│
├── 📁 docs/                     # Документация
│   ├── CityUI_Specifications.md
│   ├── CityUI_Wireframe.txt
│   ├── VERSION.md
│   ├── GIT_SETUP.md
│   ├── GITHUB_LINK.md
│   ├── UPLOAD_TO_GITHUB.md
│   └── TowerStrategy_v1.0.0.zip
│
├── README.md                    # Основная документация
├── README_EN.md                 # English documentation
├── README_UA.md                 # Українська документація
├── project.godot                # Конфигурация проекта Godot
├── LICENSE                      # Лицензия MIT
├── .gitignore                   # Git игнорирование
├── .editorconfig                # Настройки редактора
└── .gitattributes               # Git атрибуты
```

## 🎯 Преимущества новой структуры

### ✅ Организация по функциональности
- **scenes/**: Все сцены в одном месте
- **scripts/managers/**: Системные менеджеры
- **scripts/ui/**: Пользовательский интерфейс
- **scripts/gameplay/**: Игровая логика
- **scripts/data/**: Данные и константы

### ✅ Лучшая навигация
- Легко найти нужный файл
- Логическая группировка компонентов
- Четкое разделение ответственности

### ✅ Масштабируемость
- Простое добавление новых компонентов
- Готовность к росту проекта
- Стандартная структура для Godot проектов

### ✅ Поддержка команды
- Понятная структура для новых разработчиков
- Стандартизированная организация
- Легкое понимание архитектуры

## 🔧 Рекомендации по разработке

### 📝 Соглашения по именованию
- **Сцены**: PascalCase (например, `MainMenu.tscn`)
- **Скрипты**: PascalCase (например, `PlayerController.gd`)
- **Папки**: lowercase (например, `scripts/`, `assets/`)

### 📁 Размещение новых файлов
- **Новые сцены** → `scenes/`
- **UI компоненты** → `scripts/ui/`
- **Игровая логика** → `scripts/gameplay/`
- **Системные менеджеры** → `scripts/managers/`
- **Данные/константы** → `scripts/data/`
- **Ресурсы** → `assets/` (с подпапками по типу)

### 🎨 Ресурсы
- **Спрайты** → `assets/sprites/`
- **Звуки** → `assets/audio/`
- **Шрифты** → `assets/fonts/`
- **Иконки** → `assets/` (корень)

## 📋 Следующие шаги

1. **Обновить импорты** в сценах (если необходимо)
2. **Проверить работу** всех сцен
3. **Обновить документацию** при добавлении новых компонентов
4. **Следовать структуре** при дальнейшей разработке

---

**Дата рефакторинга**: 2024-09-07  
**Версия структуры**: 1.0.0