# Brew Buddy 🍵

A delightful, minimalistic iOS app that helps users track the fermentation of their kombucha with beautiful animations and timely notifications.

## Features

### ✨ Core Functionality
- **Start Fermentation Timer**: Choose from 3, 5, 7, 10, 14 days or set custom duration (1-365 days)
- **Live Countdown**: Real-time countdown showing days, hours, and minutes remaining
- **Progress Visualization**: Beautiful circular progress indicator with smooth animations
- **Push Notifications**: Get notified when your kombucha is ready to enjoy
- **Edit Duration**: Modify fermentation time even after starting
- **Finish Early**: Complete fermentation ahead of schedule with confirmation dialog
- **Rate & Notes**: Rate your kombucha (1-5 stars) and add detailed notes about your experience
- **Fermentation History**: View all your past fermentations with ratings, notes, and completion dates
- **Completion Celebration**: Delightful "Ready" screen with animations

### 🎨 Design
- **Minimalistic UI**: Clean, modern interface with subtle gradients
- **Smooth Animations**: Fluid transitions and progress animations
- **Intuitive Navigation**: Easy-to-use sheets for starting and editing fermentation
- **Visual Feedback**: Clear progress indicators and status information

### 🔧 Technical Features
- **Data Persistence**: Fermentation data survives app restarts
- **Background Timer**: Accurate countdown even when app is in background
- **Notification Management**: Proper permission handling and scheduling
- **SwiftUI**: Built with modern SwiftUI for optimal performance

## How to Use

1. **Start Fermentation**: Tap "Start Fermentation" and select your desired duration (or set custom time)
2. **Monitor Progress**: Watch the beautiful circular progress indicator and countdown
3. **Edit if Needed**: Tap "Edit Duration" to adjust fermentation time
4. **Finish Early**: Tap "Finish Early" to complete fermentation ahead of schedule
5. **Rate & Add Notes**: After completion, rate your kombucha and add detailed notes
6. **View History**: Access your fermentation history from the home screen
7. **Get Notified**: Receive a push notification when fermentation is complete
8. **Celebrate**: Enjoy the completion screen and start a new batch

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `KombuchaTrackr.xcodeproj` in Xcode
3. Build and run on your device or simulator

## Architecture

The app follows a clean MVVM architecture:

- **FermentationManager**: Core business logic and data management
- **ContentView**: Main UI with conditional rendering based on fermentation state
- **Sheet Views**: Modal interfaces for starting and editing fermentation
- **Data Models**: Simple, codable structures for fermentation data

## Future Enhancements

- Multiple batch tracking
- Temperature monitoring integration
- Recipe sharing
- Social features
- Export fermentation data
- Advanced analytics and trends

---

Made with ❤️ for kombucha enthusiasts everywhere! 