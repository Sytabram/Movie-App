# ShowApp 📺

A modern iOS application for discovering and tracking TV shows, built with Swift and UIKit. This app demonstrates advanced iOS development skills including modern UI patterns, async networking, and data persistence.

## Features

### 🏠 **Home Screen**
- **Categorized Content**: Browse shows organized by categories (Watchlist, Recommended, Popular, Horror, Crime, Documentary)
- **Horizontal Scrolling**: Smooth collection view with compositional layout
- **Dynamic Sections**: Each category displays as a separate section with custom headers

### 🔍 **Search Functionality**
- **Real-time Search**: Live search results as you type
- **Comprehensive Results**: Search across all available TV shows
- **Instant Navigation**: Tap any result to view detailed information

### 📖 **Detailed Show Information**
- **Rich Media**: High-quality poster and background images
- **Comprehensive Data**: Ratings, genres, release dates, network information
- **Smart Summaries**: HTML-parsed descriptions with "Read More" functionality
- **External Links**: Direct access to official sites and IMDB pages

### ⭐ **Watchlist Management**
- **Personal Collection**: Add/remove shows from your personal watchlist
- **Persistent Storage**: Watchlist data persists between app launches
- **Visual Feedback**: Animated checkmark confirmation when adding shows
- **Quick Access**: Watchlist appears as the first category on the home screen

## Screenshots

<div align="center">

| Home Screen | Search Results | Show Details | Search Show Details |
|-------------|----------------|--------------|------------------|
| ![Home](https://github.com/user-attachments/assets/12cb9ce8-8c0c-4d80-b94c-f1e751c40a50) | ![Search](https://github.com/user-attachments/assets/063bb9e4-2ecf-49bf-8508-ed0e71bce7dc) | ![Detail](https://github.com/user-attachments/assets/efc57fc8-2093-4871-90a1-83d926f1316c)| ![Detail Search](https://github.com/user-attachments/assets/0636686f-792a-45d2-af8e-97a39d808114) |

</div>

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

## API

This app uses the [TVMaze API](https://www.tvmaze.com/api) for show data:
- No API key required
- RESTful endpoints
- JSON responses
- High-quality images

## Installation

1. Clone the repository
2. Open `ShowApp.xcodeproj` in Xcode
3. Build and run on simulator or device
4. No additional setup required

## Technical Highlights

### 🏗️ **Architecture**
- **MVC Pattern**: Clean separation of concerns
- **Modular Design**: Each component has a single responsibility
- **Protocol-Oriented**: Extensible and testable codebase

### 🔄 **Modern iOS Features**
- **Async/Await**: Modern concurrency for network operations
- **Diffable Data Sources**: Efficient UI updates with automatic animations
- **Compositional Layout**: Flexible and responsive collection view layouts
- **Task Groups**: Concurrent API calls for improved performance

### 🌐 **Networking & Data**
- **TVMaze API Integration**: Real-time data from TVMaze REST API
- **Image Caching**: Custom image cache with memory management
- **Error Handling**: Comprehensive error management with user-friendly messages
- **JSON Decoding**: Robust Codable implementation for API responses

### 🎨 **User Interface**
- **Dark Theme**: Modern dark interface with custom colors
- **Smooth Animations**: Custom animations and transitions
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: VoiceOver support and semantic markup

### 💾 **Data Persistence**
- **UserDefaults**: Lightweight storage for watchlist data
- **Codable Persistence**: Type-safe data serialization
- **Memory Management**: Efficient image caching with automatic cleanup

## Code Structure

```
ShowApp/
├── Controllers/                      
│   ├── APIController.swift           # Network operations and API calls
│   └── DataController.swift          # Data management and persistence
├── Models/                          
│   ├── API/                         
│   │   └── ShowSearchResult.swift   # Search results wrapper
│   ├── Components/                  
│   │   ├── Externals.swift          # External references (IMDB, etc.)
│   │   ├── Geography.swift          # Country and location data
│   │   ├── MediaLinks.swift         # Images and media links
│   │   ├── Network.swift            # Broadcasting network info
│   │   ├── Rating.swift             # Show ratings
│   │   └── Schedule.swift           # Broadcast schedule
│   ├── Core/                        
│   │   ├── Image.swift              # Image metadata
│   │   ├── Show.swift               # Main show entity
│   │   └── ShowCategory.swift       # Category organization
│   ├── Errors/                      
│   │   ├── APIError.swift           # Network error types
│   │   └── DataError.swift          # Data processing errors
│   └── Presentation/                
│       └── ShowItem.swift           # View-optimized show model
├── Utilities/                       
│   ├── ErrorManager.swift           # Centralized error handling
│   └── ImageCache.swift             # Image caching system
├── Views/                          
│   ├── Cells/                       
│   │   ├── PosterCollectionViewCell.swift   # Home grid cells
│   │   └── ResultTableViewCell.swift        # Search result cells
│   ├── CustomViews/                 
│   │   ├── CheckmarkAnimationDelegate.swift # Animation coordination
│   │   └── CheckmarkView.swift              # Animated checkmark widget
│   └── SupplementaryViews/          
│       ├── SectionDetailHeaderView.swift    # Detail section headers
│       └── SectionHeaderView.swift          # Collection headers
├── ViewControllers/                 
│   ├── DetailViewController.swift   # Show details and actions
│   ├── HomeViewController.swift     # Main browsing interface
│   └── SearchViewController.swift   # Search functionality
├── Supporting Files/                
│   ├── AppDelegate.swift           # App lifecycle
│   ├── SceneDelegate.swift         # Scene management
│   └── Assets/                     # Images and resources
└── Resources/                      
    └── Localizable.strings         # Multi-language support
```

## Technical Skills Demonstrated

### Swift & iOS
- ✅ **Modern Swift**: Async/await, optionals, generics, protocols
- ✅ **UIKit Mastery**: Collection views, table views, navigation
- ✅ **Advanced Layouts**: Compositional layout, Auto Layout
- ✅ **Concurrency**: TaskGroup, MainActor, structured concurrency
- ✅ **Memory Management**: ARC, weak references, cache management

### Software Architecture
- ✅ **Design Patterns**: MVC, Singleton, Delegate, Observer
- ✅ **SOLID Principles**: Single responsibility, dependency inversion
- ✅ **Error Handling**: Custom error types, graceful degradation
- ✅ **Data Flow**: Clear separation between models and views

### iOS Frameworks
- ✅ **Foundation**: URLSession, JSONDecoder, UserDefaults
- ✅ **UIKit**: Controllers, views, animations, gestures
- ✅ **SafariServices**: In-app web browsing
- ✅ **Core Animation**: Custom animations and transitions



---

**Note**: This is a demonstration project showcasing iOS development skills. All show data is provided by the TVMaze API.

*Built by Sytabram🔨 with Swift*
