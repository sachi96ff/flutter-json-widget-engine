# JSON App Builder Engine

A powerful, highly extensible, standalone **JSON-to-Flutter-UI rendering engine**. Build entire Flutter screens or embeddable components dynamically directly from JSON configuration. 

Perfect for Server-Driven UI (SDUI), live A/B testing, no-code/low-code builders, and delivering dynamic content without pushing app updates.

---

## ✨ Features

- **100% Decoupled Architecture:** No hardcoded app dependencies. It natively uses `Theme.of(context)` to adapt to your app's Light/Dark modes instantly.
- **Advanced Caching Engine:** Built-in `JsonLoaderService` handles network requests and local caching via `shared_preferences`.
- **Native Action Registry:** Don't just show UI; trigger native Dart code (like purchases, dialogs, analytics) directly from JSON clicks.
- **Conditional Routing:** Support premium vs free user flows by pointing different user cohorts to different JSON configurations via your Flutter app logic.
- **Flexible Embedding:** Use `DynamicScreen` to render full, standalone pages, or `DynamicWidgetArea` to inject a small JSON snippet directly into an existing Flutter view.

---

## 🚀 Installation

Add it to your `pubspec.yaml` as a local path or git dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_json_dynamic_home:
    path: ../flutter-json-dynamic-home # or your specific path
```

---

## 🛠️ Quick Start

### 1. Global Setup
Configure the global network behavior in your `main.dart`. You only need to do this once.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_json_dynamic_home/flutter_json_dynamic_home.dart';

void main() {
  // Set the base URL where your JSON files are hosted
  JsonLoaderService.defaultBaseUrl = 'https://api.yourdomain.com/dynamic_ui';
  
  // (Optional) Pass API keys or Auth Tokens
  JsonLoaderService.defaultHeaders = {
    'Authorization': 'Bearer YOUR_TOKEN_HERE',
  };

  runApp(const MyApp());
}
```

### 2. Create the Engine
Create an instance of `JsonWidgetEngine`. You can pass it globally via a Provider, or instantiate it where needed.

```dart
final engine = JsonWidgetEngine();
```

---

## 📱 Displaying the UI

There are two primary ways to show your JSON-driven UI:

### A. Full Screen (`DynamicScreen`)
Use this when your JSON file represents an entire page (like a Settings page, a Profile view, or an Onboarding screen). It provides a Scaffold, an optional AppBar, and handles scrolling automatically.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DynamicScreen(
      jsonFile: 'home.json', // Will fetch from {defaultBaseUrl}/home.json
      engine: engine,
    ),
  ),
);
```

### B. Embeddable Component (`DynamicWidgetArea`)
Use this when you want to render a smaller JSON snippet *inside* an existing Flutter screen (like a dynamic promotional banner inside your static home feed).

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: ListView(
        children: [
          const Text('Static Flutter Content Here'),
          
          // Inject dynamic JSON UI cleanly!
          const DynamicWidgetArea(
            jsonFile: 'promotional_banner.json',
          ),
          
          const Text('More static content below...'),
        ],
      ),
    );
  }
}
```

### C. Dynamic URL Routing (A/B Testing, Themes, User State)

Since the `jsonFile` parameter is just a string passed from your Flutter app, you have complete control over *which* JSON file to load based on the user's current state. This is perfect for A/B testing, serving different layouts to Premium vs Free users, or loading a specific file based on the theme!

```dart
String determineScreenLayout(BuildContext context, User user) {
  // Example 1: User State (Premium vs Free)
  if (user.isPremium) return 'home_premium.json';
  
  // Example 2: Theme-based Layouts
  if (Theme.of(context).brightness == Brightness.dark) return 'home_dark.json';
  
  // Example 3: A/B Testing
  if (AppConfig.abTestGroup == 'B') return 'home_experiment_b.json';
  
  return 'home_default.json';
}

// Then simply pass it to the engine:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DynamicScreen(
      jsonFile: determineScreenLayout(context, currentUser),
      engine: engine,
    ),
  ),
);
```

### D. Custom Loading & Error States

By default, the engine shows a built-in shimmer effect while fetching the JSON, and a default error UI if it fails. You can override both to match your app's branding using `loadingWidget` and `errorBuilder`.

```dart
DynamicScreen(
  jsonFile: 'home.json',
  engine: engine,
  // Show your own custom loader
  loadingWidget: const Center(
    child: CircularProgressIndicator(color: Colors.blue),
  ),
  // Show your own custom error state
  errorBuilder: (context, error, onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Oops! No Internet connection."),
          ElevatedButton(onPressed: onRetry, child: const Text("Try Again")),
        ],
      ),
    );
  },
)
```
*(This works for both `DynamicScreen` and `DynamicWidgetArea`)*

### E. Built-in Pull-to-Refresh

You don't need to write any extra refresh logic! `DynamicScreen` supports **Pull-to-Refresh** out of the box. If the user pulls down the screen, the engine automatically fetches the fresh JSON from the network and updates the UI seamlessly.

### F. Deep Linking & Push Notifications (Pro Tip)

The engine integrates perfectly with Firebase Push Notifications or Deep Links. If your marketing team wants to launch a new promotional screen, they can just send a push notification containing the JSON file name.

**Example Push Notification Payload:**
```json
{
  "title": "50% Off Premium!",
  "body": "Tap to view today's special offers.",
  "data": {
    "action": "open_dynamic_screen",
    "json_file": "promo_50_off.json"
  }
}
```

**Flutter Handling Code:**
```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  if (message.data['action'] == 'open_dynamic_screen') {
    final jsonFile = message.data['json_file'];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicScreen(
          jsonFile: jsonFile, // Will load promo_50_off.json
          engine: engine,
        ),
      ),
    );
  }
});
```

---

## ⚡ Interactivity & Native Actions

### 1. Universal Screen Navigation (`navigate`)

The engine provides a completely automated way to navigate between dynamic screens without writing any routing code in your Flutter app! 

If you have a button in your JSON and you want it to open a new full-screen JSON layout, just use the `navigate` action. The engine will automatically push a `DynamicScreen` over the current view and load the specified file!

```json
{
  "type": "Button",
  "properties": {
    "text": "Open Details Page",
    "on_click": {
      "action": "navigate",
      "json_file": "details.json",
      "params": {
        "title": "Details Page"
      }
    }
  }
}
```

*Pro Tip: The engine is smart enough to carry over your `ActionRegistry` to the new screen automatically! This means you can infinitely chain screens and all your native handlers will continue to work.*

### 2. Custom Native Actions (`NativeActionRegistry`)

The true power of the engine lies in connecting JSON clicks to your native Dart code. You can register specific IDs in your Flutter app, and trigger them from the JSON.

#### A. Register the Action in Flutter
```dart
final engine = JsonWidgetEngine();

engine.actionRegistry.register('purchase_item', (context, params) {
  final itemId = params['item_id'];
  print("User is purchasing: $itemId");
  // Trigger your native in-app purchase logic here!
});

engine.actionRegistry.register('show_toast', (context, params) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(params['message'] ?? 'Hello!')),
  );
});
```

#### B. Trigger it from JSON
When building your JSON, use the ID you registered:
```json
{
  "type": "Button",
  "properties": {
    "text": "Buy Premium Now",
    "on_click": {
      "action": "purchase_item",
      "params": {
        "item_id": "premium_monthly_99"
      }
    }
  }
}
```

---

## 📊 Global Analytics & Tracking

The engine acts as a secure bridge. It **never** stores or sends your data to any external server. Instead, it captures analytics events from your JSON and hands them over to your Flutter app. You have 100% control over where to store or send this data (Firebase, Mixpanel, your own server).

### 1. Create your Analytics Delegate
Implement the `JsonAnalyticsDelegate` interface in your app:

```dart
import 'package:flutter_json_dynamic_home/flutter_json_dynamic_home.dart';

class MyAnalyticsHandler implements JsonAnalyticsDelegate {
  @override
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    // Send to Firebase, Mixpanel, etc.
    print("Button Clicked: $eventName with params: $parameters");
  }

  @override
  void logScreenView(String screenName) {
    // Track screen views
    print("Screen Viewed: $screenName");
  }
}
```

### 2. Pass it to the Engine
```dart
final engine = JsonWidgetEngine(
  analyticsDelegate: MyAnalyticsHandler(), // Your custom handler
);
```

### 3. Trigger Analytics from JSON
Add an `"analytics"` block to any interactive widget (like a Button). The engine will automatically fire `logEvent` *before* executing the normal `on_click` action.

```json
{
  "type": "Button",
  "analytics": {
    "event_name": "buy_premium_clicked",
    "params": {
      "location": "home_banner"
    }
  },
  "properties": {
    "text": "Buy Premium",
    "on_click": {
      "action": "navigate",
      "json_file": "premium.json"
    }
  }
}
```
*(The engine also automatically fires `logScreenView(jsonFile)` every time a screen successfully loads!)*

---

## 🔒 Visibility & Routing (Premium / Auth)

Instead of hiding individual widgets based on user state (which can get complicated and leak logic), the recommended approach is to **route users to entirely different screens** based on their status. 

### 1. Conditionally Load Different JSON Files
In your Flutter app, check the user's state and pass the appropriate JSON file to the engine:

```dart
String getHomeScreenUrl(User user) {
  if (user.isPremium) return 'home_premium.json';
  if (user.isLoggedIn) return 'home_logged_in.json';
  return 'home_guest.json';
}

// Then pass it to the DynamicScreen
DynamicScreen(
  jsonFile: getHomeScreenUrl(currentUser),
  engine: engine,
)
```

### 2. Static Visibility Toggle
If you just want to temporarily hide a widget while designing or configuring it, you can use the `visible` boolean property. If set to `false`, the engine will silently ignore the widget.

```json
{
  "type": "Card",
  "visibility": {
    "visible": false
  },
  "properties": {
    "text": "Hidden Content"
  }
}
```

---

## 🏗️ Supported Widgets

The engine supports a robust set of standard widgets.

**Content Widgets:**
- `Title` (or `H1`, `Heading`)
- `Subtitle` (or `H2`)
- `Text` (or `Paragraph`)
- `Image` (or `NetworkImage`)
- `Banner`
- `Icon`
- `Divider`

**Interactive Widgets:**
- `Button`
- `IconButton`
- `Card` (or `DynamicCard`)

**Layout & Spacing Widgets:**
- `Column`
- `Row`
- `Container`
- `Padding`
- `SizedBox` (or `Spacer`)
- `Expanded`
- `Center`
- `Grid`
- `List`
- `HorizontalList`

---

## 🎨 JSON Schema Example

Here is an example of a fully structured JSON screen config:

```json
{
  "appBarTitle": "My Dynamic Page",
  "scrollable": true,
  "background": "#F5F5F5",
  "widgets": [
    {
      "type": "Title",
      "properties": {
        "text": "Welcome Back!"
      },
      "style": {
        "margin": "16,16,8,16"
      }
    },
    {
      "type": "Card",
      "children": [
        {
          "type": "Text",
          "properties": {
            "text": "This whole card and its contents are rendered dynamically from JSON!"
          }
        },
        {
          "type": "Button",
          "properties": {
            "text": "Learn More",
            "on_click": {
              "action": "open_url",
              "url": "https://example.com"
            }
          },
          "style": {
            "margin": "16,0,0,0"
          }
        }
      ],
      "style": {
        "margin": "0,16,16,16",
        "padding": "16",
        "radius": 12,
        "background": "#FFFFFF",
        "elevation": 2
      }
    }
  ]
}
```

### Styling
The `style` object supports standard Flutter styling properties:
- `margin` and `padding` (format: `"left,top,right,bottom"` or `"all"`)
- `background` (hex color like `"#FF0000"`)
- `color` (for text/icons)
- `radius` (border radius number)
- `width` / `height` (number or `"infinity"`)
- `alignment` (`"center"`, `"topLeft"`, etc.)
- `elevation` (number)

---

Built with ❤️. Give your apps the power of dynamic content delivery.
