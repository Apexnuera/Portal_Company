# Company Portal - Setup Instructions

## Project Overview
This is a Flutter web application for the Company Portal with a responsive homepage featuring:
- Header with company logo and navigation menu
- Background image support
- Centered welcome text
- Mobile-responsive design

## Prerequisites
- Flutter SDK (3.9.2 or higher)
- Node.js (for serving the built web app)
- Chrome browser (for development)

## Project Structure
```
company_portal/
├── assets/
│   └── images/
│       ├── logo.png          (Place your company logo here)
│       └── background.jpg    (Place your background image here)
├── lib/
│   ├── main.dart            (Main application entry point)
│   └── homepage.dart        (Homepage widget with header and navigation)
├── pubspec.yaml             (Flutter dependencies)
└── package.json             (Node.js scripts)
```

## Setup Steps

### 1. Add Your Images
Place the following images in the `assets/images/` directory:
- **logo.png** - Your company logo (recommended size: 200x50px)
- **background.jpg** - Background image for the homepage (recommended size: 1920x1080px or higher)

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Install Node.js Dependencies (Optional)
```bash
npm install
```

## Running the Application

### Development Mode (with Flutter)
```bash
flutter run -d chrome
```
Or use the npm script:
```bash
npm run serve
```

### Build for Production
```bash
flutter build web
```
Or use the npm script:
```bash
npm run build
```

### Serve Production Build
After building, serve the production build using:
```bash
npm run serve-build
```
This will start a local server at http://localhost:8080

## Features

### Header Navigation
The header includes the following menu items:
- Home
- Alerts
- Campus Commune
- Buzz
- Help & Support
- Career
- Login

### Responsive Design
- **Desktop**: Full navigation menu displayed horizontally
- **Mobile/Tablet**: Hamburger menu with bottom sheet navigation

### Customization
You can customize the following in `lib/homepage.dart`:
- Navigation menu items
- Colors and styling
- Font sizes
- Background overlay opacity

## Troubleshooting

### Images Not Showing
1. Ensure images are placed in `assets/images/` directory
2. Run `flutter pub get` after adding images
3. Restart the Flutter application

### Build Issues
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## Notes
- The application uses Material Design 3
- Background image has a dark overlay for better text visibility
- Logo has a fallback placeholder if the image is not found
- All navigation items currently show a snackbar message (implement actual navigation as needed)
