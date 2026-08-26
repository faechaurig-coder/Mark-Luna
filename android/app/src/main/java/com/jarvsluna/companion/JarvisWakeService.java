// Servicio en primer plano que mantiene a JARVIS siempre activo.
// Codigo original de este proyecto.
package com.jarvsluna.companion;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

public class JarvisWakeService extends Service {

    static final String CHANNEL = "jarvis_channel";

    @Override
    public void onCreate() {
        super.onCreate();
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel c = new NotificationChannel(
                CHANNEL, "JARVIS", NotificationManager.IMPORTANCE_LOW);
            c.setDescription("JARVIS escuchando");
            nm.createNotificationChannel(c);
        }
        Notification n = new Notification.Builder(this, CHANNEL)
            .setContentTitle("🤖 JARVIS escuchando")
            .setContentText("Toca para abrir JARVIS")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .build();
        startForeground(101, n);
    }

    @Override
    public IBinder onBind(Intent intent) { return null; }
}
