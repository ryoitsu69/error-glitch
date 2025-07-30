import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15
import QtMultimedia 5.15
import SddmComponents 2.0

Rectangle {
    id: root
    
    property string notificationMessage: ""
    
    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    width: 1920
    height: 1080
    
    // Loading screen background
    Rectangle {
        id: loadingScreen
        anchors.fill: parent
        color: "#0a0a0a"
        visible: true
        
        Timer {
            id: hideLoadingTimer
            interval: 1500 // Show loading for at least 1.5 seconds
            running: videoBackground.playbackState === MediaPlayer.PlayingState
            onTriggered: {
                loadingScreen.visible = false
                // Start code wrapper animations after loading screen disappears
                codeWrapperFadeIn.start()
                animationTimer.start()
                glitchTimer.start()
            }
        }
        
        // Main loader GIF in center
        AnimatedImage {
            id: mainLoader
            anchors.centerIn: parent
            source: "resources/MainLoader.gif"
            playing: loadingScreen.visible
        }
        
        // Bottom loader GIF
        AnimatedImage {
            id: bottomLoader
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            x: parent.width * 0.8
            source: "resources/BottomLoader.gif"
            playing: loadingScreen.visible
        }
    }
    
    Video {
        id: videoBackground
        anchors.fill: parent
        source: config.background || "resources/background.mp4"
        loops: MediaPlayer.Infinite
        autoPlay: true
        volume: 0
        fillMode: VideoOutput.PreserveAspectCrop
        
        onStatusChanged: {
            console.log("Video status:", status)
            if (status === MediaPlayer.Loaded) {
                console.log("Video loaded!")
            }
        }
        
    }
    
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        visible: videoBackground.status === MediaPlayer.Loaded
    }
    
    // Error flash overlay
    Rectangle {
        id: errorFlash
        anchors.fill: parent
        color: "red"
        opacity: 0
        
        SequentialAnimation {
            id: errorAnimation
            
            NumberAnimation {
                target: errorFlash
                property: "opacity"
                to: 0.5
                duration: 100
                easing.type: Easing.InQuad
            }
            
            NumberAnimation {
                target: errorFlash
                property: "opacity"
                to: 0
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
    }
    
    
    Item {
        id: codeWrapper
        width: 500
        height: 350
        visible: false
        opacity: 0
        transformOrigin: Item.Center
        focus: true
        
        property real baseY: root.height - height
        property real baseX: root.width * 0.7 - width / 2
        
        // Synchronized rotation and Y movement
        rotation: rotationValue
        y: baseY + yOffset + glitchY
        x: baseX + glitchX
        
        property real rotationValue: 0
        property real yOffset: 0
        property real glitchX: 0
        property real glitchY: 0
        
        property int animDuration: 2750
        
        // Fade in animation
        SequentialAnimation {
            id: codeWrapperFadeIn
            PropertyAction { target: codeWrapper; property: "visible"; value: true }
            NumberAnimation { target: codeWrapper; property: "opacity"; to: 1; duration: 800; easing.type: Easing.InOutQuad }
        }
        
        // Glitch effect timer
        Timer {
            id: glitchTimer
            running: false
            repeat: false
            interval: 2000
            
            onTriggered: {
                // Calculate displacement amount
                var maxX = root.width * 0.05
                var maxY = root.height * 0.05
                
                // Check current position boundaries
                var currentX = codeWrapper.baseX + codeWrapper.glitchX
                var currentY = codeWrapper.baseY + codeWrapper.yOffset + codeWrapper.glitchY
                
                var goLeft = (currentX + codeWrapper.width + maxX > root.width)
                var goUp = (currentY + codeWrapper.height + maxY > root.height)
                
                // Calculate new displacement (accumulative)
                var newGlitchX = codeWrapper.glitchX + (goLeft ? -maxX : maxX)
                var newGlitchY = codeWrapper.glitchY + (goUp ? -maxY : maxY)
                
                // Randomize for more variety
                if (Math.random() > 0.5) newGlitchX = codeWrapper.glitchX
                if (Math.random() > 0.5) newGlitchY = codeWrapper.glitchY
                
                // Ensure at least one axis glitches
                if (newGlitchX === codeWrapper.glitchX && newGlitchY === codeWrapper.glitchY) {
                    newGlitchX = codeWrapper.glitchX + (goLeft ? -maxX : maxX)
                }
                
                glitchAnimation.glitchXTarget = newGlitchX
                glitchAnimation.glitchYTarget = newGlitchY
                
                console.log("Glitch triggered: X=" + glitchAnimation.glitchXTarget + " Y=" + glitchAnimation.glitchYTarget)
                glitchAnimation.start()
                
                // Set next interval and restart
                interval = 1000 + Math.random() * 2000
                restart()
            }
            
            Component.onCompleted: {
                interval = 1000 + Math.random() * 2000
            }
        }
        
        
        // Glitch animation
        SequentialAnimation {
            id: glitchAnimation
            
            property real glitchXTarget: 0
            property real glitchYTarget: 0
            
            // Hide wrapper
            PropertyAction {
                target: codeWrapper
                property: "visible"
                value: false
            }
            
            // Set new position instantly
            PropertyAction {
                target: codeWrapper
                property: "glitchX"
                value: glitchAnimation.glitchXTarget
            }
            
            PropertyAction {
                target: codeWrapper
                property: "glitchY"
                value: glitchAnimation.glitchYTarget
            }
            
            // Wait
            PauseAnimation { duration: 200 }
            
            // Show wrapper
            PropertyAction {
                target: codeWrapper
                property: "visible"
                value: true
            }
        }
        
        Timer {
            id: animationTimer
            running: false
            repeat: true
            interval: 100
            
            property bool goingPositive: true
            
            onTriggered: {
                // When animation finishes, reverse direction and set new random duration
                if (!posAnimation.running && !negAnimation.running) {
                    goingPositive = !goingPositive
                    codeWrapper.animDuration = 2800 + Math.random() * 400 // 2800-3200ms
                    
                    if (goingPositive) {
                        posAnimation.start()
                    } else {
                        negAnimation.start()
                    }
                }
            }
            
            Component.onCompleted: {
                // Start with positive direction
                codeWrapper.animDuration = 2800 + Math.random() * 400
                posAnimation.start()
            }
        }
        
        ParallelAnimation {
            id: posAnimation
            
            NumberAnimation {
                target: codeWrapper
                property: "rotationValue"
                to: 5
                duration: codeWrapper.animDuration
                easing.type: Easing.InOutSine
            }
            
            NumberAnimation {
                target: codeWrapper
                property: "yOffset"
                to: -15
                duration: codeWrapper.animDuration
                easing.type: Easing.InOutSine
            }
        }
        
        ParallelAnimation {
            id: negAnimation
            
            NumberAnimation {
                target: codeWrapper
                property: "rotationValue"
                to: -5
                duration: codeWrapper.animDuration
                easing.type: Easing.InOutSine
            }
            
            NumberAnimation {
                target: codeWrapper
                property: "yOffset"
                to: 15
                duration: codeWrapper.animDuration
                easing.type: Easing.InOutSine
            }
        }
        
        // Semi-transparent black background
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }
        
        // Code text background
        Item {
            anchors.fill: parent
            anchors.bottomMargin: 50
            clip: true
            
            Column {
                id: codeColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: -200
                anchors.rightMargin: -200
                spacing: 2
                
                Repeater {
                    model: 25
                    Text {
                        id: codeLine
                        width: parent.width
                        color: "#ffffff"
                        opacity: 1.0
                        font.pixelSize: 8
                        font.family: "monospace"
                        text: ""
                        renderType: Text.NativeRendering
                        antialiasing: false
                        elide: Text.ElideNone
                        
                        property var codeSnippets: [
                            "const handleLogin = async (username, password) => {",
                            "    try {",
                            "        const response = await fetch('/api/auth/login', {",
                            "            method: 'POST',",
                            "            headers: { 'Content-Type': 'application/json' },",
                            "            body: JSON.stringify({ username, password })",
                            "        });",
                            "        if (!response.ok) throw new Error('Login failed');",
                            "        const { token } = await response.json();",
                            "        localStorage.setItem('authToken', token);",
                            "        return { success: true };",
                            "    } catch (error) {",
                            "        console.error('Login error:', error);",
                            "        return { success: false, error: error.message };",
                            "    }",
                            "};",
                            "if (process.env.NODE_ENV === 'production') {",
                            "    app.use(compression());",
                            "    app.use(helmet());",
                            "}",
                            "const middleware = compose([authMiddleware, corsMiddleware, rateLimitMiddleware]);",
                            "export const API_ENDPOINTS = {",
                            "    AUTH: '/api/v1/auth',",
                            "    USERS: '/api/v1/users',",
                            "    ADMIN: '/api/v1/admin'",
                            "} as const;",
                            "interface User extends BaseEntity {",
                            "    id: string;",
                            "    email: string;",
                            "    passwordHash: string;",
                            "    roles: Role[];",
                            "    createdAt: Date;",
                            "    updatedAt: Date;",
                            "}",
                            "@Injectable()",
                            "@Controller('auth')",
                            "export class AuthController {",
                            "    constructor(private readonly authService: AuthService) {}",
                            "    @Post('login')",
                            "    async login(@Body() dto: LoginDto): Promise<TokenResponse> {",
                            "        return this.authService.login(dto);",
                            "    }",
                            "}",
                            "#include <iostream>",
                            "#include <vector>",
                            "#include <algorithm>",
                            "template<typename T>",
                            "class SecureContainer {",
                            "private:",
                            "    std::vector<T> data;",
                            "    mutable std::mutex mtx;",
                            "public:",
                            "    void push(T&& value) {",
                            "        std::lock_guard<std::mutex> lock(mtx);",
                            "        data.push_back(std::forward<T>(value));",
                            "    }",
                            "};",
                            "SELECT u.id, u.username, u.email, r.name as role",
                            "FROM users u",
                            "LEFT JOIN user_roles ur ON u.id = ur.user_id",
                            "LEFT JOIN roles r ON ur.role_id = r.id",
                            "WHERE u.active = true AND u.deleted_at IS NULL;",
                            "#!/usr/bin/env python3",
                            "import asyncio",
                            "from typing import Optional, Dict, Any",
                            "async def authenticate(credentials: Dict[str, str]) -> Optional[str]:",
                            "    \"\"\"Authenticate user and return JWT token\"\"\"",
                            "    async with aiohttp.ClientSession() as session:",
                            "        async with session.post(AUTH_URL, json=credentials) as resp:",
                            "            if resp.status == 200:",
                            "                data = await resp.json()",
                            "                return data.get('token')",
                            "    return None",
                            "function validateInput(input) {",
                            "    const trimmed = input.trim();",
                            "    if (trimmed.length < 3) return false;",
                            "    if (trimmed.length > 50) return false;",
                            "    return /^[a-zA-Z0-9_-]+$/.test(trimmed);",
                            "}",
                            "class SessionManager {",
                            "    constructor() {",
                            "        this.sessions = new Map();",
                            "        this.timeout = 3600000; // 1 hour",
                            "    }",
                            "    createSession(userId, data) {",
                            "        const sessionId = crypto.randomUUID();",
                            "        this.sessions.set(sessionId, {",
                            "            userId,",
                            "            data,",
                            "            createdAt: Date.now()",
                            "        });",
                            "        return sessionId;",
                            "    }",
                            "    getSession(sessionId) {",
                            "        const session = this.sessions.get(sessionId);",
                            "        if (!session) return null;",
                            "        if (Date.now() - session.createdAt > this.timeout) {",
                            "            this.sessions.delete(sessionId);",
                            "            return null;",
                            "        }",
                            "        return session;",
                            "    }",
                            "}",
                            "import { useState, useEffect } from 'react';",
                            "import { useRouter } from 'next/router';",
                            "",
                            "export default function LoginForm() {",
                            "    const [credentials, setCredentials] = useState({",
                            "        username: '',",
                            "        password: ''",
                            "    });",
                            "    const [isLoading, setIsLoading] = useState(false);",
                            "    const router = useRouter();",
                            "",
                            "    const handleSubmit = async (e) => {",
                            "        e.preventDefault();",
                            "        setIsLoading(true);",
                            "        const result = await handleLogin(credentials);",
                            "        if (result.success) {",
                            "            router.push('/dashboard');",
                            "        }",
                            "        setIsLoading(false);",
                            "    };",
                            "    return (",
                            "        <form onSubmit={handleSubmit}>",
                            "            {/* Form content */}",
                            "        </form>",
                            "    );",
                            "}"
                        ]
                        
                        Timer {
                            interval: 330
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered: {
                                var snippet = codeLine.codeSnippets[Math.floor(Math.random() * codeLine.codeSnippets.length)];
                                var indent = Math.floor(Math.random() * 8) * 4; // Random indentation 0-28 spaces
                                var spaces = " ".repeat(indent);
                                codeLine.text = spaces + snippet;
                                
                                // Random chance to add extra code at the end
                                if (Math.random() > 0.7) {
                                    codeLine.text += " // " + ["TODO: fix this", "FIXME", "deprecated", "v2.0", "legacy code", "optimize later"][Math.floor(Math.random() * 6)];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Console input line at bottom
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            height: 30
            
            property string inputText: ""
            property string loginState: "normal" // normal, username, password
            property string username: ""
            property string prompt: ""
            
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: 0
                
                Text {
                    text: parent.parent.prompt
                    color: "#00ff00"
                    font.pixelSize: 8
                    font.family: "monospace"
                    renderType: Text.NativeRendering
                    antialiasing: false
                }
                
                Text {
                    text: parent.parent.loginState === "password" ? "*".repeat(parent.parent.inputText.length) : parent.parent.inputText
                    color: "#ffffff"
                    font.pixelSize: 8
                    font.family: "monospace"
                    renderType: Text.NativeRendering
                    antialiasing: false
                }
                
                Text {
                    id: cursor
                    text: "_"
                    color: "#ffffff"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.bold: true
                    renderType: Text.NativeRendering
                    antialiasing: false
                    
                    SequentialAnimation on opacity {
                        running: true
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            to: 0
                            duration: 500
                        }
                        
                        NumberAnimation {
                            to: 1
                            duration: 500
                        }
                    }
                }
            }
            
            // MouseArea to capture focus
            MouseArea {
                anchors.fill: parent
                onClicked: hiddenInput.forceActiveFocus()
            }
            
            // Invisible TextInput to capture keyboard input
            TextInput {
                id: hiddenInput
                width: 0
                height: 0
                focus: true
                
                onTextChanged: {
                    parent.inputText = text
                }
                
                Keys.onPressed: {
                    // Handle Ctrl+Z to reset to initial state
                    if (event.key === Qt.Key_Z && (event.modifiers & Qt.ControlModifier)) {
                        parent.loginState = "normal"
                        parent.prompt = ""
                        parent.username = ""
                        parent.inputText = ""
                        text = ""
                        event.accepted = true
                        return
                    }
                    
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (parent.loginState === "normal") {
                            var command = text.toLowerCase()
                            
                            // Check for commands (case insensitive)
                            if (command === "hodor") {
                                parent.loginState = "username"
                                parent.prompt = "login: "
                                text = ""
                                parent.inputText = ""
                            } else if (command === "hodor restart") {
                                if (sddm.canReboot) {
                                    sddm.reboot()
                                }
                                text = ""
                                parent.inputText = ""
                            } else if (command === "hodor shutdown") {
                                if (sddm.canPowerOff) {
                                    sddm.powerOff()
                                }
                                text = ""
                                parent.inputText = ""
                            } else if (text !== "") {
                                // Wrong command - show error
                                errorAnimation.start()
                                text = ""
                                parent.inputText = ""
                            }
                        } else if (parent.loginState === "username") {
                            parent.username = text
                            parent.loginState = "password"
                            parent.prompt = "password: "
                            text = ""
                            parent.inputText = ""
                        } else if (parent.loginState === "password") {
                            // Perform login
                            nameField.text = parent.username
                            passwordField.text = text
                            sddm.login(parent.username, text, session.index)
                            
                            // Reset state
                            parent.loginState = "normal"
                            parent.prompt = ""
                            parent.username = ""
                            text = ""
                            parent.inputText = ""
                        }
                    } else if (event.key === Qt.Key_Backspace && text.length > 0) {
                        text = text.substring(0, text.length - 1)
                        parent.inputText = text
                    }
                }
                
                Component.onCompleted: {
                    forceActiveFocus()
                }
            }
        }
        
        // Advanced 3D border with gradient effect
        Item {
            anchors.fill: parent
            
            // Outer frame with gradient
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 0
                
                // Top border with gradient
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#e0e0e0" }
                        GradientStop { position: 0.3; color: "#d0d0d0" }
                        GradientStop { position: 0.7; color: "#b8b8b8" }
                        GradientStop { position: 1.0; color: "#a0a0a0" }
                    }
                }
                
                // Left border with gradient
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#e0e0e0" }
                        GradientStop { position: 0.3; color: "#d0d0d0" }
                        GradientStop { position: 0.7; color: "#b8b8b8" }
                        GradientStop { position: 1.0; color: "#a0a0a0" }
                    }
                }
                
                // Bottom border with gradient
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#606060" }
                        GradientStop { position: 0.3; color: "#505050" }
                        GradientStop { position: 0.7; color: "#404040" }
                        GradientStop { position: 1.0; color: "#303030" }
                    }
                }
                
                // Right border with gradient
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 8
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#606060" }
                        GradientStop { position: 0.3; color: "#505050" }
                        GradientStop { position: 0.7; color: "#404040" }
                        GradientStop { position: 1.0; color: "#303030" }
                    }
                }
                
                // Corner pieces with diagonal pattern
                Canvas {
                    id: topLeftCorner
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 8
                    height: 8
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        
                        // Diagonal lines pattern
                        ctx.strokeStyle = "#c0c0c0";
                        ctx.lineWidth = 0.5;
                        for (var i = 0; i < 16; i += 2) {
                            ctx.beginPath();
                            ctx.moveTo(0, i);
                            ctx.lineTo(i, 0);
                            ctx.stroke();
                        }
                        
                        // Gradient overlay
                        var gradient = ctx.createLinearGradient(0, 0, width, height);
                        gradient.addColorStop(0, "rgba(224, 224, 224, 0.8)");
                        gradient.addColorStop(1, "rgba(160, 160, 160, 0.8)");
                        ctx.fillStyle = gradient;
                        ctx.fillRect(0, 0, width, height);
                    }
                }
                
                Canvas {
                    id: bottomRightCorner
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 8
                    height: 8
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        
                        // Diagonal lines pattern
                        ctx.strokeStyle = "#404040";
                        ctx.lineWidth = 0.5;
                        for (var i = 0; i < 16; i += 2) {
                            ctx.beginPath();
                            ctx.moveTo(width - i, height);
                            ctx.lineTo(width, height - i);
                            ctx.stroke();
                        }
                        
                        // Gradient overlay
                        var gradient = ctx.createLinearGradient(0, 0, width, height);
                        gradient.addColorStop(0, "rgba(96, 96, 96, 0.8)");
                        gradient.addColorStop(1, "rgba(48, 48, 48, 0.8)");
                        ctx.fillStyle = gradient;
                        ctx.fillRect(0, 0, width, height);
                    }
                }
            }
            
            // Inner bevel
            Item {
                anchors.fill: parent
                anchors.margins: 8
                
                // Inner highlight
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width - 1
                    height: 1
                    color: "#f0f0f0"
                    opacity: 0.6
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 1
                    height: parent.height - 1
                    color: "#f0f0f0"
                    opacity: 0.6
                }
                
                // Inner shadow
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#202020"
                    opacity: 0.6
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 1
                    height: parent.height
                    color: "#202020"
                    opacity: 0.6
                }
            }
        }
    }
    
    // Hidden login components (required by SDDM)
    TextField {
        id: nameField
        visible: false
        text: userModel.lastUser
    }
    
    TextField {
        id: passwordField
        visible: false
        echoMode: TextInput.Password
    }
    
    Text {
        id: errorMessage
        visible: false
        text: notificationMessage
    }
    
    // Session selector at top right
    FancyComboBox {
        id: session
        anchors {
            top: parent.top
            right: parent.right
            margins: 20
        }
        model: sessionModel
        width: 200
        textRole: "name"
        
        property int index: 0
        Component.onCompleted: {
            if (sessionModel.lastIndex !== undefined) {
                index = sessionModel.lastIndex
            }
        }
    }
    
    
    Connections {
        target: sddm
        onLoginSucceeded: {
            errorMessage.text = ""
        }
        
        onLoginFailed: {
            notificationMessage = qsTr("Login Failed")
            passwordField.text = ""
            errorAnimation.start()
            
            // Reset terminal state and refocus input
            var consoleInput = codeWrapper.children[codeWrapper.children.length - 2]
            consoleInput.loginState = "normal"
            consoleInput.prompt = ""
            consoleInput.username = ""
            consoleInput.inputText = ""
            
            // Clear and refocus the hidden input
            hiddenInput.text = ""
            hiddenInput.forceActiveFocus()
        }
    }
    
    Component.onCompleted: {
        if (nameField.text == "") {
            nameField.visible = true
            nameField.forceActiveFocus()
        } else {
            passwordField.forceActiveFocus()
        }
    }
}
