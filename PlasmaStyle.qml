pragma Singleton
import QtQuick 2.15

QtObject {
    // Plasma-like colors
    property color backgroundColor: "#31363b"
    property color textColor: "#eff0f1"
    property color highlightColor: "#3daee9"
    property color highlightedTextColor: "#eff0f1"
    property color linkColor: "#2980b9"
    property color visitedLinkColor: "#7f8c8d"
    property color negativeTextColor: "#da4453"
    property color neutralTextColor: "#f67400"
    property color positiveTextColor: "#27ae60"
    
    // Component colors
    property color buttonBackgroundNormal: "#31363b"
    property color buttonBackgroundHover: "#3f444a"
    property color buttonBackgroundPressed: "#2a2e32"
    
    // Shadows and effects
    property color shadowColor: "#000000"
    property real shadowOpacity: 0.3
    property int shadowRadius: 6
    
    // Spacing and sizes
    property int smallSpacing: 4
    property int largeSpacing: 8
    property int defaultRadius: 3
    
    // Animations
    property int shortDuration: 150
    property int longDuration: 250
}