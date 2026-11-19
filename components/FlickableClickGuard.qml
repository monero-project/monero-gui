import QtQuick

// Place above the Flickable so the first press reaches the control under the pointer.
MouseArea {
    id: root
    required property Flickable flickable

    anchors.fill: flickable
    enabled: flickable.interactive && flickable.moving

    onPressed: (mouse) => {
        flickable.cancelFlick();
        if (flickable.moving) {
            // Qt can retain a trackpad gesture at the edge even after the animation stops.
            suspendInteraction.when = true;
            suspendInteraction.when = false;
            flickable.cancelFlick();
        }
        mouse.accepted = false;
    }

    Binding {
        id: suspendInteraction
        target: root.flickable
        property: "interactive"
        value: false
        when: false
    }

    // Qt can still report a touchpad gesture in progress after cancelFlick().
    // A positive pressDelay lets the Flickable replay that press to its child.
    Binding {
        target: root.flickable
        property: "pressDelay"
        value: 1
        when: root.enabled
    }
}
