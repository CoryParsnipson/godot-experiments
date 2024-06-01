package org.godotengine.plugin.stepscounter

import android.app.ForegroundServiceStartNotAllowedException
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.util.Log
import androidx.core.app.NotificationCompat

class StepsCounterService : Service() {
    enum class Action {
        START_FOREGROUND,
        STOP_FOREGROUND,
    }

    companion object {
        @JvmStatic val TAG = StepsCounterService::class.simpleName
        @JvmStatic val channelId = "${BuildConfig.GODOT_PLUGIN_NAME}Channel"
        @JvmStatic val channelDesc = "${BuildConfig.GODOT_PLUGIN_NAME} Step Counter Service"
        @JvmStatic val notificationId = 903
    }

    private val startServiceResult = START_STICKY
    private val stopForegroundServiceStrategy = STOP_FOREGROUND_DETACH

    private val messenger = Messenger(object: Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            Log.v(TAG, "inside handle message...")
        }
    })

    /**
     * Start this as a foreground service. Does the standard permission check and then calling
     * startForegroundService().
     *
     * Run this when you want the step counter sensor data events in the foreground (running when
     * the parent app is not running), as opposed to a background service, which will only run
     * when the parent app is running.
     */
    private fun startForeground() {
        for (perm in PermissionManager.neededPermissions) {
            if (!PermissionManager.hasPermission(this, perm)) {
                Log.w(TAG, "Could not start foreground service because $perm is not granted.")
                stopSelf()
                return
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
            this.startForeground(notificationId, notification)
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && e is ForegroundServiceStartNotAllowedException) {
               // TODO: show some error message to the user?
            }
        }

        Log.v(TAG, "Foreground service running...")
    }

    private fun stopForeground() {
        Log.v(TAG, "Stopping foreground service...")
        stopForeground(stopForegroundServiceStrategy)
    }

    private fun createNotificationChannel() {
        // TODO: this should be moved somewhere else
        val mChannel = NotificationChannel(channelId, channelId, NotificationManager.IMPORTANCE_DEFAULT)
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

        Log.v(TAG, "[onStartCommand] received intent with action: ${action.toString()}")

        when (action) {
            Action.START_FOREGROUND -> { startForeground() }
            Action.STOP_FOREGROUND -> { stopForeground() }
            else -> {
                Log.w(TAG, "Received unknown action in onStartCommand(): ${action.toString()}")
            }
        }

        return startServiceResult
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.v(TAG, "Destroying service...")
    }

    override fun onBind(intent: Intent): IBinder {
        return messenger.binder
    }
}