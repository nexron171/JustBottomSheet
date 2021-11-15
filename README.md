***Just Bottom Sheet***

<img src="https://devnex-2796b.web.app/just_bottom_sheet/example.gif" height="400"/>

Bottom sheet with properly working nested scroll and swipe to close gesture.

## Features

- Highly customizable
- Close only by drag handler or by drag handler and scroll
- Supports any scrolls inside including slivers
- More features soon

## Usage

Just call function:

```dart
showJustBottomSheet(...);
```
or you can present through your own route:
```dart
Navigator.of(context).push(YourRoute(builder: (context) {
    return JustBottomSheetPage(...);
}));
```