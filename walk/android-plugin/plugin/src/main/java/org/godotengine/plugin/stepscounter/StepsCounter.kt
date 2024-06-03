package org.godotengine.plugin.stepscounter

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.os.RemoteException
import android.util.Log
import android.widget.Toast
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotAndroidPlugin(godot: Godot): GodotPlugin(godot) {
    enum class StepsCounterMessage {
        STEPS_COUNT_UPDATED,
        STEPS_COUNTER_ACCURACY_CHANGED
        ;

        companion object {
            fun fromInt(value: Int) = StepsCounterMessage.values().first { it.ordinal == value }
        }

        fun getKey(): String {
            when (this) {
                STEPS_COUNT_UPDATED -> return "steps"
                STEPS_COUNTER_ACCURACY_CHANGED -> return "accuracy"
            }
        }
    }

    companion object {
        @JvmStatic var showToast = false
    }

    private val messengerRx = Messenger(object: Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            try {
                val action = StepsCounterMessage.fromInt(msg.what)
                when (action) {
                    StepsCounterMessage.STEPS_COUNT_UPDATED -> {
                        val stepsSinceLastReboot = msg.data.getLong(action.getKey())
                        emitSignal("on_step_counter_updated", stepsSinceLastReboot)
                    }
                    StepsCounterMessage.STEPS_COUNTER_ACCURACY_CHANGED -> {
                        val accuracy = msg.data.getInt(action.getKey())
                        emitSignal("on_step_counter_accuracy_changed", accuracy)
                    }
                }
            } catch (e: NoSuchElementException) {
                Log.w(pluginName, "[Messenger.handleMessage] Received unknown msg.what: ${msg.what}")
            }
        }
    })
    private var stepsCounterServiceMessenger: Messenger? = null
    private val stepsCounterServiceConnection = object: ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            Log.v(pluginName, "stepsCounterServiceConnection connected")
            stepsCounterServiceMessenger = Messenger(service)
            sendMessage(StepsCounterService.MessageAction.CLIENT_CONNECTED)
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.v(pluginName, "stepsCounterServiceConnection disconnected")
            stepsCounterServiceMessenger = null
        }
    }

    override fun getPluginName() = BuildConfig.GODOT_PLUGIN_NAME

    @UsedByGodot
    private fun enableToast() {
        showToast = true
    }

    @UsedByGodot
    private fun disableToast() {
        showToast = false
    }

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        val signals = HashSet<SignalInfo>()

        // Need to use KClass<T>::class.java*ObjectType* not KClass<T>::class.java; seriously... wtf
        // the latter is a java primitive (i.e. int or long) while the former is the boxed object
        // In Kotlin, there is no way to deal with primitives directly, so what would happen is that
        // you pass this function a Long, for example, and it complains that the arg type is
        // wrong and it's expecting a `long`...
        signals.add(SignalInfo("on_step_counter_updated", Long::class.javaObjectType))
        signals.add(SignalInfo("on_step_counter_accuracy_changed", Int::class.javaObjectType))

        return signals
    }

    @UsedByGodot
    @Suppress("DEPRECATION")
    private fun isStepsCounterServiceRunning(): Boolean {
        return (this.activity?.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager)
            .getRunningServices(Integer.MAX_VALUE)
            .any {
                Log.v(pluginName, "running service: ${it.service.className}")
                return it.service.className == StepsCounterService::class.qualifiedName
            }
    }

    private fun bindStepsCounterService(bindOption: Int = 0) {
        val context = this.activity!!.applicationContext
        val intent = Intent(context, StepsCounterService::class.java)
        this.activity!!.bindService(intent, stepsCounterServiceConnection, bindOption)
    }

    private fun unbindStepsCounterService() {
        if (stepsCounterServiceMessenger == null) {
            return
        }

        sendMessage(StepsCounterService.MessageAction.CLIENT_DISCONNECTED)
        this.activity!!.unbindService(stepsCounterServiceConnection)
        Log.v(pluginName, "[unbindStepsCounterService] unbinding complete")
    }

    override fun onGodotSetupCompleted() {
        super.onGodotSetupCompleted()

        Log.v(pluginName, "is StepsCounterService running? ${isStepsCounterServiceRunning()}")

        // rebind to service if it is already running from before
        if (isStepsCounterServiceRunning()) {
            Log.v(pluginName, "[onGodotSetupCompleted] found running StepsCounterService. Rebinding...")
            bindStepsCounterService()
        } else {
            Log.v(pluginName, "[onGodotSetupCompleted] StepsCounterService not running...")
        }
    }

    override fun onMainDestroy() {
        super.onMainDestroy()
        unbindStepsCounterService()
    }

    override fun onMainRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ) {
        super.onMainRequestPermissionsResult(requestCode, permissions, grantResults)
        PermissionManager.onPermissionsRequestResult(requestCode, permissions, grantResults)
    }

    @UsedByGodot
    private fun hasPermission(permission: String): Boolean {
        if (this.activity == null || this.activity?.applicationContext == null) {
            Log.e(pluginName, "Plugin activity is null!")
            return false
        }
        return PermissionManager.hasPermission(this.activity?.applicationContext!!, permission)
    }

    // It's recommended to use OS.request_permission() in godot since that's available from the engine.
    // This is implemented here for completeness sake. The result callback for this will return in
    // the onMainRequestPermissionsResult() function.
    @UsedByGodot
    private fun requestPermission(permission: String) {
        return PermissionManager.requestPermission(this.activity!!, permission)
    }

    // the intended permissions request flow is to check hasPermission first, then query this
    // command to determine if you should show an in context UI explaining to the user why you need
    // a specific permission, and lastly requestPermission() to let the user grant/deny.
    @UsedByGodot
    private fun shouldShowRequestPermissionRationale(permission: String): Boolean {
        return PermissionManager.shouldShowRequestPermissionRationale(this.activity!!, permission)
    }

    /**
     * Provide this stub function for users to call to check if everything is loaded and working.
     */
    @UsedByGodot
    private fun healthCheck() {
        runOnUiThread {
            val msg:String = getPluginName() + " is running!"
            if (showToast) {
                Toast.makeText(activity, msg, Toast.LENGTH_LONG).show()
            }
            Log.v(pluginName, msg)

            Log.v(pluginName, "Checking permissions:")
            for (perm in PermissionManager.neededPermissions) {
                hasPermission(perm)
            }
        }
    }

    private fun sendMessage(msg: StepsCounterService.MessageAction) {
        try {
            val message = Message.obtain(null, msg.ordinal)
            message.replyTo = messengerRx
            stepsCounterServiceMessenger?.send(message)
        } catch (e: RemoteException) {
            Log.w(pluginName, "[unbindStepsCounterService] remote service has crashed.")
        }
    }

    @UsedByGodot
    private fun updateStepsCounterInfo() {
        sendMessage(StepsCounterService.MessageAction.QUERY_STEPS)
        sendMessage(StepsCounterService.MessageAction.QUERY_ACCURACY)
    }

    @UsedByGodot
    private fun startStepsCounterForegroundService() {
        if (isStepsCounterServiceRunning()) {
            Log.v(pluginName, "StepsCounterService is already running, skipping start")
            updateStepsCounterInfo()
            return
        }

        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        intent.putExtra("action", StepsCounterService.ServiceAction.START_FOREGROUND)
        context.startForegroundService(intent)

        bindStepsCounterService()
    }

    @UsedByGodot
    private fun stopStepsCounterForegroundService() {
        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        intent.putExtra("action", StepsCounterService.ServiceAction.STOP_FOREGROUND)
        context.startService(intent);
    }

    @UsedByGodot
    private fun stopStepsCounterService() {
        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        context.stopService(intent);

        unbindStepsCounterService()
    }
}
