package org.godotengine.plugin.stepscounter

import android.app.ForegroundServiceStartNotAllowedException
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class StepsCounterService : Service() {
    enum class Action {
        START,
        START_FOREGROUND,
        START_BACKGROUND,
        STOP,
        STOP_FOREGROUND,
        STOP_BACKGROUND,
    }
    companion object {
        @JvmStatic val TAG = "StepsCounterService"
        @JvmStatic val serviceId = 903
        @JvmStatic val channelId = "${BuildConfig.GODOT_PLUGIN_NAME}Channel"
        @JvmStatic val channelDesc = "${BuildConfig.GODOT_PLUGIN_NAME} Step Counter Service"
    }

    /**
     * Start this as a foreground service. Does the standard permission check and then calling
     * startForegroundService().
     *
     * Run this when you want the step counter sensor data events in the foreground (running when
     * the parent app is not running), as opposed to a background service, which will only run
     * when the parent app is running.
     */
    private fun startForeground(): Int {
        for (perm in PermissionManager.neededPermissions) {
            if (!PermissionManager.hasPermission(this, perm)) {
                Log.w(TAG, "Could not start foreground service because ${perm} is not granted.")
                return stop()
            }
        }

        createNotificationChannel()
        Log.v(TAG, "Starting as foreground service...")

        try {
            val notification = NotificationCompat.Builder(this, channelId).build()

            // According to the docs, we *should* be able to use `ServiceCompat.startForeground()`
            // but for some reason on my Pixel 2 physical device running Android 11 (code name R, API 29)
            // the ServiceCompat.startForeground() call throws a fatal exception saying that the
            // overload with 4 parameters does not exist. No idea why...
            this.startForeground(serviceId, notification)
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && e is ForegroundServiceStartNotAllowedException) {
               // TODO: show some error message to the user?
            }
        }

        Log.v(TAG, "Foreground service running...")
        return serviceId
    }

    private fun stopForeground(): Int {
        Log.v(TAG, "Stopping foreground service...")
        stopForeground()
        return serviceId
    }

    private fun stop(): Int {
        stopForeground()
        stopSelf()
        return serviceId
    }

    private fun createNotificationChannel() {
        // TODO: this should be moved somewhere else
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val mChannel = NotificationChannel(channelId, channelId, importance)
        mChannel.description = channelDesc

        // Register the channel with the system. You can't change the importance
        // or other notification behaviors after this.
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(mChannel)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)

        val action = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getSerializableExtra("action", Action::class.java)
        } else {
            @Suppress("Deprecation")
            intent?.getSerializableExtra("action") as Action
        }

        when (action) {
            Action.START_FOREGROUND -> { return startForeground() }
            Action.STOP_FOREGROUND -> { return stopForeground() }
            Action.STOP -> { return stop() }
            else -> {
                Log.w(TAG, "Received unknown action in onStartCommand(): ${action.toString()}")
                return serviceId
            }
        }
    }

    override fun onBind(p0: Intent?): IBinder? {
        TODO("Not yet implemented")
    }
}