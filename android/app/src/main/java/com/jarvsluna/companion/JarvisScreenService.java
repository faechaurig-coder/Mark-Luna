// Accesibilidad (opcional) para leer la estructura de pantalla.
// Codigo original de este proyecto.
package com.jarvsluna.companion;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.util.Log;

public class JarvisScreenService extends AccessibilityService {

    private static final String TAG = "JarvisACS";

    @Override
    public void onAccessibilityEvent(AccessibilityEvent e) {
        // Read current window structure for "que hay en pantalla".
        AccessibilityNodeInfo root = getRootInActiveWindow();
        if (root != null) {
            StringBuilder sb = new StringBuilder();
            describe(root, sb, 0);
            Log.i(TAG, "SCREEN|" + sb);
        }
    }

    private void describe(AccessibilityNodeInfo n, StringBuilder sb, int depth) {
        if (depth > 12 || sb.length() > 4000) return;
        if (n.getText() != null) sb.append(n.getText()).append("|");
        if (n.getContentDescription() != null) sb.append(n.getContentDescription()).append("|");
        for (int i = 0; i < n.getChildCount(); i++) describe(n.getChild(i), sb, depth + 1);
    }

    @Override
    public void onInterrupt() { }
}
