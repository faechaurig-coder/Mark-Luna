// Escucha de notificaciones: lee WhatsApp, llamadas, etc.
// Codigo original de este proyecto.
package com.jarvsluna.companion;

import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

public class JarvisNotificationListener extends NotificationListenerService {

    private static final String TAG = "JarvisNLS";

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        String pkg = sbn.getPackageName();
        // Solo apps de mensajeria por ahora.
        if (!pkg.contains("whatsapp") && !pkg.contains("messenger") && !pkg.contains("telegram")
            && !pkg.contains("sms") && !pkg.contains("dialer")) {
            return;
        }
        CharSequence title = sbn.getNotification().extras.getCharSequence("android.title");
        CharSequence text  = sbn.getNotification().extras.getCharSequence("android.text");
        Log.i(TAG, "NOTIF|" + pkg + "|" + title + "|" + text);
        // Aqui se conectaria con la PWA o con la API de Gemini para responder.
    }
}
