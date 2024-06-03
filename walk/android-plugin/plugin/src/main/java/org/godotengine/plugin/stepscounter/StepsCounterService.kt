package org.godotengine.plugin.stepscounter

import android.app.ForegroundServiceStartNotAllowedException
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.os.RemoteException
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.async

class StepsCounterService : Service() {
    enum class ServiceAction {
        START_FOREGROUND,
        STOP_FOREGROUND,
    }

    enum class MessageAction {
        CLIENT_CONNECTED,
        CLIENT_DISCONNECTED
        ;

        companion object {
            fun fromInt(value: Int) = MessageAction.values().first { it.ordinal == value }
        }
    }

    companion object {
        @JvmStatic val TAG = StepsCounterService::class.simpleName
        @JvmStatic val channelId = "${BuildConfig.GODOT_PLUGIN_NAME}Channel"
        @JvmStatic val channelDesc = "${BuildConfig.GODOT_PLUGIN_NAME} Step Counter Service"
        @JvmStatic val notificationId = 903
    }

    private val startServiceResult = START_STICKY
    private val stopForegroundServiceStrategy = STOP_FOREGROUND_DETACH
    private val clients = ArrayList<Messenger>()
    private val messengerRx = Messenger(object: Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            try {
                val msgAction = MessageAction.fromInt(msg.what)
                when (msgAction) {
                    MessageAction.CLIENT_CONNECTED -> {
                        Log.v(TAG, "[Messenger.CLIENT_CONNECTED] Connecting client ${msg.replyTo}")
                        clients.add(msg.replyTo)
                    }
                    MessageAction.CLIENT_DISCONNECTED -> {
                        Log.v(TAG, "[Messenger.CLIENT_DISCONNECTED] Disconnecting client ${msg.replyTo}")
                        clients.remove(msg.replyTo)
                    }
                }
            } catch (e: NoSuchElementException) {
                Log.w(TAG, "[Messenger.handleMessage] Received unknown msg.what: ${msg.what}")
            }
        }
    })

    private val stepsCounterListener = StepsCounterListener()
    private var mainLoopJob: Job? = null

    private fun sendMessage(msg: GodotAndroidPlugin.StepsCounterMessage, stepsCount: Long) {
        val message = Message.obtain(null, msg.ordinal)
        message.data.putLong(msg.getKey(), stepsCount)
        return sendMessage(message)
    }

    private fun sendMessage(msg: GodotAndroidPlugin.StepsCounterMessage, accuracy: Int) {
        val message = Message.obtain(null, msg.ordinal)
        message.data.putInt(msg.getKey(), accuracy)
        return sendMessage(message)
    }

    private fun sendMessage(msg: Message) {
        // go through list backwards so we can remove from it during iteration
        for (id in clients.size - 1 downTo 0) {
           try {
               clients[id].send(msg)
           } catch (e: RemoteException) {
               clients.removeAt(id)
           }
        }
    }

    override fun onBind(intent: Intent): IBinder {
        return messengerRx.binder
    }

    @OptIn(DelicateCoroutinesApi::class)
    private fun runServiceMainLoop() {
        Log.v(TAG, "Service body is running...")
        // this might be a hack, since it's strongly encouraged to not use async declarations that
        // can escape a runBlocking scope, but I have no idea how this suspendCancellationCoroutine
        // is supposed to work. The examples online are pretty minimal and don't go very deep into
        // the client side usage.
        //
        // I think you're supposed to use this running along side other  coroutines which form your
        // app business logic, whereas here we are fitting it into a non-async framework, which is
        // why we have this async call.
        mainLoopJob = GlobalScope.async {
            stepsCounterListener.registerListener(
                { steps -> sendMessage(GodotAndroidPlugin.StepsCounterMessage.STEPS_COUNT_UPDATED, steps) },
                { accuracy -> sendMessage(GodotAndroidPlugin.StepsCounterMessage.STEPS_COUNTER_ACCURACY_CHANGED, accuracy) }
            )
        }
    }

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
        runServiceMainLoop()
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
            intent?.getSerializableExtra("action", ServiceAction::class.java)
        } else {
            @Suppress("Deprecation")
            intent?.getSerializableExtra("action") as ServiceAction
        }

        Log.v(TAG, "[onStartCommand] received intent with action: ${action.toString()}")

        when (action) {
            ServiceAction.START_FOREGROUND -> { startForeground() }
            ServiceAction.STOP_FOREGROUND -> { stopForeground() }
            else -> {
                Log.w(TAG, "Received unknown action in onStartCommand(): ${action.toString()}")
            }
        }

        return startServiceResult
    }

    override fun onDestroy() {
        super.onDestroy()
        mainLoopJob?.cancel()
        stepsCounterListener.unregisterListener()

        Log.v(TAG, "Destroying service...")
    }
}