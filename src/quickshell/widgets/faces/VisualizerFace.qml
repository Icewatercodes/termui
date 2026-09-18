import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../reusables"
import "../../"

Item {
    id: root
    anchors.fill: parent

    property real minWidth: 50
    property real minHeight: 50
    property real maxWidth: 99999
    property real maxHeight: 99999
    property real minAspect: 0
    property real maxAspect: 99999

    property bool isVisVisible: visible

    onIsVisVisibleChanged: {
        if (isVisVisible) Cava.registerConsumer();
        else Cava.unregisterConsumer();
    }

    Component.onCompleted: {
        if (isVisVisible) Cava.registerConsumer();
    }

    Component.onDestruction: {
        if (isVisVisible) Cava.unregisterConsumer();
    }

    // Layout configuration
    property real barSpacing: Scaler.s(0)
    property real minBarWidth: Scaler.s(30)
    property int activeBars: Math.max(4, Math.min(128, Math.floor((width + barSpacing) / (minBarWidth + barSpacing))))
    property real actualBarWidth: (width - (activeBars - 1) * barSpacing) / activeBars

    property var rawBarLevels: Cava.barLevels
    property var processedBars: {
        let source = rawBarLevels;
        let count = activeBars;
        let out = [];

        if (!source || source.length === 0) {
            for (let i = 0; i < count; i++) out.push(0.0);
            return out;
        }

        let srcLen = source.length;
        let half = (count - 1) / 2;

        for (let i = 0; i < count; i++) {
            // Distance from center (0 at the center, 1 at the edges)
            let distFromCenter = Math.abs(i - half);
            let norm = half > 0 ? (distFromCenter / half) : 0;
            
            // --- BASS IN THE MIDDLE & HIGHER BASS CUTOFF ---
            // Power curve < 1.0 expands the low frequency indexes across more center bars
            let frequencyMap = Math.pow(norm, 0.3); 
            let pos = frequencyMap * (srcLen - 1);
            
            let idx0 = Math.floor(pos);
            let idx1 = Math.min(srcLen - 1, idx0 + 1);
            let frac = pos - idx0;

            let v0 = source[idx0] || 0.0;
            let v1 = source[idx1] || 0.0;
            let rawVal = v0 + (v1 - v0) * frac;

            // Sensitivity and gate filter
            let val = rawVal < 0.02 ? 0.0 : (rawVal - 0.02) / 0.98;
            val = Math.max(0.0, Math.min(1.0, val));

            out.push(val);
        }

        return out;
    }

    property var barLevels: processedBars

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height
        spacing: root.barSpacing

        Repeater {
            model: root.activeBars
            delegate: Rectangle {
                width: root.actualBarWidth
                height: Math.max(Scaler.s(2), level * parent.height)
                
                // Normal standard clean CAVA layout looks
                topLeftRadius: width * 0.35
                topRightRadius: width * 0.35
                bottomLeftRadius: 0
                bottomRightRadius: 0
                
                color: ThemeBackend.mauve
                opacity: 0.4 + (level * 0.6)
                anchors.bottom: parent.bottom

                property real level: (root.barLevels && index < root.barLevels.length) ? root.barLevels[index] : 0.0

                Behavior on height {
                    NumberAnimation {
                        duration: 65
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
}
