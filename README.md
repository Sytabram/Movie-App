# ShowApp 📺

A modern iOS application for discovering and tracking TV shows, built with Swift and UIKit. This app demonstrates advanced iOS development skills including modern UI patterns, async networking, and data persistence.

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
