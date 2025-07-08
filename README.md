# SportTimer

Приложение для iOS для отслеживания спортивных тренировок с таймером и историей тренировок.

## Скриншоты

### Главный экран
![Главный экран](screenshots/home_screen.png)

### Таймер тренировки
![Таймер](screenshots/timer_screen.png)

### История тренировок
![История](screenshots/history_screen.png)

### Профиль пользователя
![Профиль](screenshots/profile_screen.png)

## Архитектурные решения

### 1. Архитектурный паттерн MVVM

Приложение следует архитектуре **Model-View-ViewModel** с четким разделением ответственности:

```
SportTimer/
├── Model/                    # Модели данных
│   └── DateRange.swift      # Модель для фильтрации по датам
├── View/                    # Представления (SwiftUI)
│   ├── MainView.swift       # Главное представление с TabView
│   ├── Home/                # Главный экран
│   ├── Timer/               # Экран таймера
│   ├── History/             # Экран истории
│   └── Profile/             # Экран профиля
├── ViewModel/               # Бизнес-логика
│   ├── TimerViewModel.swift
│   ├── WorkoutViewModel.swift
│   ├── ProfileViewModel.swift
│   └── SettingsManager.swift
├── Utils/                   # Утилиты
│   └── Constants.swift
└── Persistence.swift        # Core Data контроллер
```

### 2. Компонентная архитектура

Каждый экран разделен на переиспользуемые компоненты:

#### Home экран
- `StatCard.swift` - Карточка статистики
- `WorkoutCard.swift` - Карточка тренировки
- `EmptyStateView.swift` - Состояние пустого экрана

#### Timer экран
- `CircularProgressView.swift` - Круговой прогресс-бар
- `WorkoutTypeSelector.swift` - Селектор типа тренировки
- `TimerControlButtons.swift` - Кнопки управления таймером

#### History экран
- `HistoryWorkoutCard.swift` - Карточка тренировки в истории
- `FilterChip.swift` - Чип фильтрации
- `FilterDateButton.swift` - Кнопка фильтрации по дате
- `FilterTypeButton.swift` - Кнопка фильтрации по типу
- `FilterSheet.swift` - Модальное окно фильтрации

#### Profile экран
- `StatisticsCard.swift` - Карточка статистики профиля
- `SettingsRow.swift` - Строка настроек
- `ImagePicker.swift` - Выбор изображения профиля

### 3. Асинхронность и многопоточность

Приложение использует современные подходы Swift Concurrency:

#### TimerViewModel
- **Async/await таймер**: Использует `Task.sleep(nanoseconds:)` вместо Foundation Timer
- **@MainActor**: Безопасность UI потока
- **Background execution**: Поддержка работы в фоне через `UIBackgroundTaskIdentifier`


#### Core Data операции
- **Background context**: Все операции сохранения выполняются в фоновом контексте
- **NSPersistentHistoryTracking**: Отслеживание изменений данных
- **Automatic merging**: Автоматическое объединение изменений из разных контекстов


#### Асинхронный поиск
- **Debouncing**: Задержка поиска на 300ms для предотвращения частых запросов
- **Task cancellation**: Отмена предыдущих поисковых запросов
- **Non-blocking UI**: Поиск не блокирует пользовательский интерфейс


#### Core Data Stack
- **Background saving**: Все сохранения в фоновом режиме

#### UserDefaults
- **Async wrapper**: Асинхронная обертка для UserDefaults операций
- **Type safety**: Типобезопасные операции с настройками

#### Масштабируемость
- Модульная структура компонентов
- Повторное использование кода
- Простое добавление новых функций

#### Производительность
- Асинхронные операции не блокируют UI
- Оптимизированные Core Data запросы
- Эффективное управление памятью

## Инструкции по запуску

### Системные требования

- **iOS Deployment Target**: 16.0 или выше
- **Swift**: 5.7 или выше

### Установка и запуск

1. **Клонирование репозитория**
   ```bash
   git clone https://github.com/ewrika/SportTimer.git
   cd SportTimer
   ```

2. **Открытие в Xcode**
   ```bash
   open SportTimer.xcodeproj
   ```

### Структура проекта

```
SportTimer.xcodeproj/
├── SportTimer/
│   ├── SportTimerApp.swift          # Главный файл приложения
│   ├── Model/                       # Модели данных
│   ├── View/                        # SwiftUI представления
│   ├── ViewModel/                   # Бизнес-логика
│   ├── Utils/                       # Утилиты и константы
│   ├── Persistence.swift            # Core Data контроллер
│   ├── Assets.xcassets/             # Ресурсы приложения
│   └── SportTimer.xcdatamodeld/     # Core Data модель
```


### Возможности
- ⏱️ Таймер тренировки с возможностью паузы
- 📊 Статистика тренировок
- 📝 История всех тренировок
- 🔍 Поиск и фильтрация тренировок
- 👤 Профиль пользователя с настройками
- 📱 Работа в фоновом режиме
- 🌙 Поддержка темной темы
