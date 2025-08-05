# Настройка Git репозитория для Tower Strategy

## 📋 Предварительные требования

### 1. Установка Git

#### Windows:
1. Скачайте Git с официального сайта: https://git-scm.com/download/win
2. Запустите установщик и следуйте инструкциям
3. Перезапустите командную строку/PowerShell

#### macOS:
```bash
# Через Homebrew
brew install git

# Или скачайте с официального сайта
```

#### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install git
```

### 2. Настройка Git (первый раз)
```bash
git config --global user.name "Ваше Имя"
git config --global user.email "ваш.email@example.com"
```

## 🚀 Создание репозитория

### 1. Инициализация Git
```bash
cd "C:\Users\GAMING PC\Documents\towerstrategy"
git init
```

### 2. Добавление файлов
```bash
git add .
```

### 3. Первый коммит
```bash
git commit -m "Initial commit: Tower Strategy Game v1.0.0

- Городской интерфейс с пиксель-арт дизайном
- Система подземелий с процедурной генерацией
- Мобильная оптимизация (9:16)
- Система управления героями
- Интерактивные кнопки с анимацией"
```

## 🌐 Создание репозитория на GitHub

### 1. Создайте репозиторий на GitHub
1. Перейдите на https://github.com
2. Нажмите "New repository"
3. Название: `tower-strategy`
4. Описание: `Мобильная игра в жанре стратегии с элементами рогалика на Godot 4`
5. Выберите "Public" или "Private"
6. **НЕ** ставьте галочки на "Add a README file" и "Add .gitignore"
7. Нажмите "Create repository"

### 2. Подключение к удаленному репозиторию
```bash
git remote add origin https://github.com/YOUR_USERNAME/tower-strategy.git
git branch -M main
git push -u origin main
```

## 📁 Структура файлов в репозитории

```
towerstrategy/
├── .gitignore              # Git игнорирование
├── LICENSE                 # MIT лицензия
├── README.md              # Документация проекта
├── GIT_SETUP.md           # Инструкции по настройке Git
├── project.godot          # Файл проекта Godot
├── Main.tscn              # Главная сцена
├── MainMap.gd             # Логика карты мира
├── MainMap.tscn           # Сцена карты мира
├── CityUI.tscn            # Городской интерфейс
├── CityUI.gd              # Логика городского UI
├── CityUIButton.gd        # Кнопки городского UI
├── DungeonManager.gd      # Менеджер подземелий
├── DungeonScene.tscn      # Сцена подземелья
├── DungeonScene.gd        # Логика подземелья
├── Hero.gd                # Система героев
├── Hero.tscn              # Сцена героя
├── Party.gd               # Управление отрядом
├── Party.tscn             # Сцена отряда
├── TeamManager.gd         # Менеджер команды
├── MapGenerator.gd        # Генератор карты
├── MapController.gd       # Контроллер карты
├── MapNode.gd             # Узел карты
├── MapPoint.gd            # Точка карты
├── MapPointButton.gd      # Кнопка точки карты
├── MapPoint.tscn          # Сцена точки карты
├── PointMarker.gd         # Маркер точки
├── PointMarker.tscn       # Сцена маркера
├── ExpeditionMap.gd       # Карта экспедиции
├── ExpeditionMap.tscn     # Сцена карты экспедиции
├── BattleScene.gd         # Сцена боя
├── BattleScene.tscn       # Сцена боя
├── EventManager.gd        # Менеджер событий
├── map_constants.gd       # Константы карты
├── map_point_data.gd      # Данные точек карты
├── CityUI_Specifications.md # Технические спецификации UI
├── CityUI_Wireframe.txt   # Wireframe схемы
├── assets/                # Ресурсы игры
│   └── sprites/          # Спрайты
└── icon.svg              # Иконка проекта
```

## 🔄 Работа с репозиторием

### Ежедневная работа:
```bash
# Проверить статус
git status

# Добавить изменения
git add .

# Создать коммит
git commit -m "Описание изменений"

# Отправить на GitHub
git push
```

### Получение обновлений:
```bash
git pull origin main
```

## 🏷️ Создание релизов

### 1. Создание тега
```bash
git tag -a v1.0.0 -m "Версия 1.0.0 - Первый релиз"
git push origin v1.0.0
```

### 2. Создание релиза на GitHub
1. Перейдите в раздел "Releases" на GitHub
2. Нажмите "Create a new release"
3. Выберите тег v1.0.0
4. Добавьте описание изменений
5. Нажмите "Publish release"

## 🐛 Решение проблем

### Если Git не найден:
1. Убедитесь, что Git установлен
2. Перезапустите командную строку
3. Проверьте переменные среды PATH

### Если не удается подключиться к GitHub:
1. Проверьте интернет-соединение
2. Убедитесь, что репозиторий создан на GitHub
3. Проверьте правильность URL

### Если файлы не добавляются:
1. Проверьте .gitignore
2. Убедитесь, что находитесь в правильной папке
3. Используйте `git add -A` для добавления всех файлов

## 📞 Поддержка

Если у вас возникли проблемы с настройкой Git или репозитория, обратитесь к:
- [Документация Git](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Godot Documentation](https://docs.godotengine.org/)

---

**Удачной разработки! 🎮** 