# FiveM Accessibility System

A comprehensive accessibility resource for FiveM servers that provides visual filters, emergency lighting controls, weather management, and text-to-speech functionality to make gameplay more accessible for all players.

## Features

### 🎨 Visual Accessibility
- **Color Filters**: Dimming, grayscale, high contrast, and color tint filters
- **Color Blindness Support**: Specialized filters for protanopia, deuteranopia, and tritanopia
- **Emergency Lighting Control**: Toggle flashing lights on emergency vehicles
- **Weather Control**: Lock weather to prevent sudden bright flashes

### 🔊 Audio Accessibility
- **Text-to-Speech**: Simple command-based TTS system for nearby players
- **Multiple Commands**: `/tts`, `/speak`, and `/say` for convenience
- **Distance-Based**: Only nearby players hear the TTS output
- **Input Validation**: Prevents spam with character limits and cooldowns

### 🎛️ User Interface
- **ox_lib Integration**: Modern, accessible menu system
- **Fallback Support**: Works with ESX, QBCore, or standalone
- **Persistent Settings**: Player preferences saved across sessions
- **Multiple Access Methods**: Commands, aliases, and menu shortcuts

## Installation

### Prerequisites
Before installing this accessibility system, ensure you have:
- **xsound**: Required for text-to-speech functionality
- **ox_lib**: Required for modern UI and notifications
- **oels**: Enhanced emergency lighting system (if using custom lighting features)

### Step 1: Replace Dependencies

#### Replace xsound
1. **Stop your server**
2. **Backup your current xsound folder** (just in case)
3. **Delete your existing `xsound` resource folder**
4. **Replace it with the xsound folder provided** in this package
5. The provided xsound includes TTS enhancements needed for this system

#### Replace oels Files  
1. **Navigate to your `oels` resource folder**
2. **Backup your current oels files** (recommended)
3. **Replace the files in your oels folder with the ones provided** in this package
4. This ensures compatibility with the emergency lighting toggle features

### Step 2: Install Accessibility System
1. **Extract the accessibility folder** to your `resources` directory
2. **Add to your server.cfg**:
   ```cfg
   ensure ox_lib
   ensure xsound
   ensure oels
   ensure accessibility
   ```
3. **Restart your server**

### Step 3: Verify Installation
1. **Join your server**
2. **Test the main menu**: `/accessibility`
3. **Test text-to-speech**: `/tts Hello world`
4. **Check console for**: `[Accessibility] Resource started successfully!`

## Usage

### Commands

#### Main Accessibility Menu
- `/accessibility` - Open the main accessibility menu
- `/eoa` - Ease of Access menu (alias)
- `/access` - Alternative menu command (alias)
- `/a11y` - Accessibility menu (short alias)

#### Text-to-Speech
- `/tts [message]` - Speak text to nearby players
- `/speak [message]` - Same as /tts
- `/say [message]` - Same as /tts
- `/ttshelp` - Show TTS help and examples

#### Individual Toggle Commands
- `/accessibility [option]` - Toggle specific option
  - Example: `/accessibility dim` - Toggle dimming filter
  - Example: `/accessibility lighting` - Toggle emergency lighting

#### Debug and Testing
- `/debugaccessibility` - Show current settings and debug info
- `/testfilter [name]` - Test visual filters directly

### Available Options

#### Visual Filters
- **dim** - Dimming filter to reduce brightness
- **blackwhite** - Grayscale/black and white filter
- **highcontrast** - High contrast filter
- **brown** - Brown tint filter
- **blue** - Blue tint filter  
- **green** - Green tint filter
- **orange** - Orange tint filter

#### Color Blindness Assistance
- **protanopia** - Red color blindness filter
- **deuteranopia** - Green color blindness filter
- **tritanopia** - Blue color blindness filter

#### Environmental Controls
- **lighting** - Emergency vehicle lighting control
- **weather** - Static weather control (locks to cloudy)

## Configuration

### Basic Settings
Edit `config.lua` to customize:

```lua
-- Text-to-Speech Settings
Config.TextToSpeech = {
    command = "tts",           -- Main command
    language = "en-US",        -- TTS language
    maxDistance = 5.0,         -- Hearing distance
    volume = 0.7,              -- Volume level
    maxTextLength = 200,       -- Character limit
    cooldown = 3000           -- Cooldown in ms
}
```

### Advanced Configuration
- **Notification System**: Supports ox_lib, ESX, QBCore with fallbacks
- **Framework Integration**: Auto-detects ESX/QBCore or runs standalone
- **Custom Filters**: Add your own visual filters in advanced config
- **Database Integration**: Optional MySQL storage for settings

## Troubleshooting

### Common Issues

#### "xsound resource not found"
- **Solution**: Ensure xsound is installed and started before accessibility
- **Check**: `ensure xsound` is in your server.cfg above `ensure accessibility`

#### Menu not opening
- **Solution**: Ensure ox_lib is installed and started
- **Fallback**: The system will use simple chat notifications if ox_lib fails

#### TTS not working
- **Check Server Console**: Look for "Found X nearby players" messages
- **Test Command**: Try `/tts test` and check console output
- **Verify Distance**: Make sure other players are within the configured distance

#### Visual filters not applying
- **Solution**: Only one filter can be active at a time
- **Check**: Use `/debugaccessibility` to see current states
- **Reset**: Disable all filters and try enabling one at a time

### Console Messages
Normal operation should show:
```
[Accessibility] Resource started successfully!
[Accessibility] Found X nearby players
[Accessibility] TTS request processed successfully
```

Error messages will be in red (`^1`) and should be reported for support.

## Support

### Getting Help
1. **Check console messages** for error details
2. **Use debug command**: `/debugaccessibility`
3. **Test individual components** with specific commands
4. **Check dependencies** are installed and updated

### Reporting Issues
When reporting issues, please include:
- FiveM server version
- Error messages from console
- Output from `/debugaccessibility`
- Steps to reproduce the issue

## Credits

- **xsound Integration**: Enhanced for TTS functionality
- **oels Compatibility**: Emergency lighting system integration
- **ox_lib Integration**: Modern UI framework
- **Community Feedback**: Accessibility improvements based on user needs

## License

This accessibility system is designed to make FiveM more inclusive and accessible for all players. Use responsibly and consider the needs of your community when configuring options.

---

**Version**: 2.0  
**Last Updated**: October 2024  
**Compatibility**: FiveM Latest, ox_lib, xsound, oels