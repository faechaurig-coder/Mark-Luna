// JARVIS Companion — bridge nativo para la PWA.
// Codigo original de este proyecto: recibe la config de la PWA y mantiene
// a JARVIS siempre escuchando en Android.
package com.jarvsluna.companion;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {

    // Se guarda llave + ajustes copiados desde la PWA y se pasan al servicio.

    @Override
    protected void onCreate(Bundle saved) {
        super.onCreate(saved);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        int pad = getDpi(20);
        root.setPadding(pad, pad, pad, pad);

        TextView title = new TextView(this);
        title.setText("🤖 JARVIS Companion");
        title.setTextSize(22);
        root.addView(title);

        TextView sub = new TextView(this);
        sub.setText("Pega tu config de la PWA (Settings → Exportar) o tu llave y JARVIS queda siempre activo.");
        sub.setTextSize(14);
        root.addView(sub);

        final EditText input = new EditText(this);
        input.setHint("jv_key en texto o JSON con jv_key");
        root.addView(input);

        Button start = new Button(this);
        start.setText("Activar JARVIS siempre");
        root.addView(start);

        start.setOnClickListener(v -> {
            String cfg = input.getText().toString().trim();
            getSharedPreferences("jarvis", MODE_PRIVATE).edit().putString("cfg", cfg).apply();
            Intent svc = new Intent(this, JarvisWakeService.class);
            if (startForegroundService(svc) != null) {
                sub.setText("✅ JARVIS activo y escuchando incluso con la pantalla apagada.");
            }
        });
        setContentView(root);
    }

    private int getDpi(int dp) {
        return (int) (dp * getResources().getDisplayMetrics().density);
    }
}
