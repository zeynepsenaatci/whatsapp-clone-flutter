# WhatsApp Clone Flutter App

A modern WhatsApp clone built with Flutter, featuring dark/light theme support and a beautiful UI.

## Features

- 🎨 **Dark/Light Theme Support** - Automatic theme switching based on system preferences
- 📱 **Responsive Design** - Works on all screen sizes
- 🔍 **Search Functionality** - Search bar with theme-aware styling
- 📋 **Custom Tab Navigation** - Customizable tab buttons with theme colors
- 🎯 **Popup Menu** - WhatsApp-style popup menu with options
- 🎨 **Custom Theme System** - Extensible theme system with custom colors
- 📱 **Bottom Navigation** - TabBar-based bottom navigation
- 🌍 **Multi-language Support** - Turkish language support

## Screenshots

### Light Theme
- Welcome Page
- Login Page with Country Picker
- Verification Page
- User Info Page
- Home Page with Custom Tabs

### Dark Theme
- All pages with dark theme support
- Automatic theme switching

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/whatsapp-clone-flutter.git
cd whatsapp-clone-flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── common/
│   ├── extension/
│   │   └── custom_theme_extension.dart
│   ├── helper/
│   │   └── show_alert_dialog.dart
│   ├── theme/
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   ├── utils/
│   │   └── coloors.dart
│   └── widgets/
│       ├── custom_elevated_button.dart
│       ├── custom_icon_button.dart
│       └── custom_text_field.dart
├── feature/
│   ├── auth/
│   │   ├── pages/
│   │   │   ├── home_page.dart
│   │   │   ├── login_page.dart
│   │   │   ├── user_info_page.dart
│   │   │   └── verification_page.dart
│   │   └── widgets/
│   │       └── custom_text_field.dart
│   └── welcome/
│       ├── pages/
│       │   └── welcome_page.dart
│       └── widgets/
│           └── privacyandterms.dart
└── main.dart
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  country_picker: ^2.0.25
  flutter_native_splash: ^2.3.10
```

## Theme System

The app uses a custom theme system with the following features:

### Custom Colors
- `greenDark` / `greenLight` - Primary green colors
- `blueDark` / `blueLight` - Secondary blue colors
- `greyDark` / `greyLight` - Grey colors for text
- `backgroundDark` / `backgroundLight` - Background colors
- `searchDark` / `searchLight` - Search bar colors
- `tabDark` / `tabLight` - Tab button colors

### Theme Extension
The `CustomThemeExtension` provides theme-aware colors that automatically adapt to light/dark themes.

## Features in Detail

### Home Page
- Custom search bar with theme colors
- Custom tab buttons (Tümü, Okunmamış, Favoriler, Gruplar)
- Popup menu with options (Sohbet seç, Tümü okundu, Yeni sohbet)
- Bottom navigation with 5 tabs
- Theme-aware styling

### Authentication Flow
- Welcome page with privacy terms
- Login page with country picker
- Phone number verification
- User info collection

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- WhatsApp for the UI inspiration
- All contributors and supporters

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter) - email@example.com

Project Link: [https://github.com/yourusername/whatsapp-clone-flutter](https://github.com/yourusername/whatsapp-clone-flutter)
