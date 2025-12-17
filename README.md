# Tourscribe iOS App

A comprehensive travel planning and management iOS application built with SwiftUI following MVVM architecture.

## Features Implemented (UI Only)

### Must-Have Features
- **Authentication**: Login/Signup with email verification support
- **Profile Management**: User profile with personal information and preferences
- **Trip Planning**: Create and manage travel itineraries with activities
- **Expense Tracking**: Track and categorize travel expenses with currency support
- **Ranking System**: User ranking based on travel distance and countries visited
- **AskMe Chatbot**: Travel-focused chatbot with different modes

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:
- **Models**: Data structures for User, Trip, Expense, etc.
- **ViewModels**: Business logic and state management
- **Views**: SwiftUI user interface components

## Project Structure

```
TourscribeApp/
├── Models/
│   ├── User.swift
│   ├── Trip.swift
│   └── Expense.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── TripViewModel.swift
│   ├── ExpenseViewModel.swift
│   ├── ChatViewModel.swift
│   └── RankingViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── Auth/
│   │   └── AuthView.swift
│   ├── Trip/
│   │   ├── TripListView.swift
│   │   └── TripDetailView.swift
│   ├── Expense/
│   │   └── ExpenseListView.swift
│   ├── Ranking/
│   │   └── RankingView.swift
│   ├── Chat/
│   │   └── ChatView.swift
│   └── Profile/
│       └── ProfileView.swift
└── TourscribeApp.swift
```

## TODO: Implementation Tasks

### Authentication (AuthViewModel)
- [ ] Integrate AWS Cognito for user authentication
- [ ] Implement email verification flow
- [ ] Add password reset functionality
- [ ] Handle authentication state persistence

### Trip Planning (TripViewModel)
- [ ] Integrate Google Places API for location search
- [ ] Implement route optimization algorithms
- [ ] Add weather API integration
- [ ] Create PDF generation for trip sharing
- [ ] Implement trip data persistence

### Expense Tracking (ExpenseViewModel)
- [ ] Add currency conversion API integration
- [ ] Implement expense data persistence
- [ ] Create expense report generation (PDF/shareable link)
- [ ] Add expense visualization with Charts framework

### Ranking System (RankingViewModel)
- [ ] Calculate travel distances between locations
- [ ] Implement ranking algorithm
- [ ] Add leaderboard data management
- [ ] Create shareable ranking reports

### AskMe Chatbot (ChatViewModel)
- [ ] Integrate ChatGPT API
- [ ] Implement travel-specific prompt engineering
- [ ] Add conversation history persistence
- [ ] Implement usage limits for different subscription tiers

### General Implementation
- [ ] Set up Core Data or CloudKit for data persistence
- [ ] Implement network layer with proper error handling
- [ ] Add offline support where applicable
- [ ] Implement push notifications
- [ ] Add accessibility support
- [ ] Create unit and UI tests
- [ ] Implement analytics and crash reporting

### API Integrations Needed
- [ ] AWS Cognito (Authentication)
- [ ] Google Places API (Location search and details)
- [ ] Weather API (Trip weather information)
- [ ] Currency Exchange API (Real-time conversion)
- [ ] OpenAI ChatGPT API (Chatbot functionality)
- [ ] Maps API (Route optimization and visualization)

### UI Enhancements
- [ ] Add loading states and error handling UI
- [ ] Implement pull-to-refresh functionality
- [ ] Add haptic feedback
- [ ] Create custom animations and transitions
- [ ] Implement dark mode support
- [ ] Add localization support

## Design Principles

- **User-Centric**: Intuitive navigation with tab-based structure
- **Responsive**: Adaptive layouts for different screen sizes
- **Accessible**: VoiceOver support and proper contrast ratios
- **Performance**: Lazy loading and efficient data management
- **Security**: Secure authentication and data handling

## Getting Started

1. Open the project in Xcode
2. Install required dependencies
3. Configure API keys for external services
4. Build and run the project

## Notes

This is currently a UI-only implementation. All business logic marked with TODO comments needs to be implemented for a fully functional application.
