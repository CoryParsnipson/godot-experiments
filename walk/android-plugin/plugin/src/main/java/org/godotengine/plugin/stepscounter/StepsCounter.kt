package org.godotengine.plugin.stepscounter

import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import android.widget.Toast
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import kotlin.concurrent.thread
import kotlin.coroutines.resume

class GodotAndroidPlugin(godot: Godot): GodotPlugin(godot) {
    companion object {
        @JvmStatic var showToast = false
    }

    private val sensorManager by lazy {
        this.activity!!.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }
    private val sensor: Sensor? by lazy {
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
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

    private suspend fun steps() = suspendCancellableCoroutine { continuation ->
        Log.d(pluginName, "Registering sensor listener...")

        val listener: SensorEventListener by lazy {
            object: SensorEventListener {
                override fun onSensorChanged(event: SensorEvent?) {
                    if (event == null) return

                    val stepsSinceLastReboot = event.values[0].toLong()
                    Log.d(pluginName, "Steps since last reboot: $stepsSinceLastReboot")
                    emitSignal("on_step_counter_updated", stepsSinceLastReboot)

                    if (continuation.isActive) {
                        continuation.resume(stepsSinceLastReboot)
                    }
                }

                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                    Log.d(pluginName, "Accuracy changed to: $accuracy")
                }
            }
        }

        // note: calling this function multiple times will register multiple listeners
        // and thus will cause you to receive multiple callbacks for the same step count (need
        // to keep track in member state so we only register this once)
        val supportedAndEnabled = sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_UI)
        Log.d(pluginName, "Sensor listener registered: $supportedAndEnabled")
    }

    @UsedByGodot
    private fun checkSteps() {
        // we started a new thread so the suspendable coroutine doesn't block the execution of the JNI caller's thread
        // what the Google docs say is that you're supposed to start a foreground service with this code
        // inside it. It's not entirely clear to me what a foreground service is and what is can do, but
        // I assume that it won't matter if that thread gets blocked just counting steps.
        thread(start = true) {
            Log.v(pluginName, "checkSteps(): created new thread for steps() coroutine")
            runBlocking {
                steps()
            }
            Log.v(pluginName, "checkSteps(): killing thread")
        }
    }

    @UsedByGodot
    private fun startStepsCounterForegroundService() {
        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        intent.putExtra("action", StepsCounterService.Action.START_FOREGROUND)

        Log.v(pluginName, "Starting foreground service...")
        context.startForegroundService(intent)
    }

    @UsedByGodot
    private fun stopStepsCounterForegroundService() {
        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        intent.putExtra("action", StepsCounterService.Action.STOP_FOREGROUND)

        Log.v(pluginName, "Stopping foreground service...")
        context.stopService(intent);
    }

    @UsedByGodot
    private fun stopStepsCounterService() {
        val context = this.activity?.applicationContext!!;
        val intent = Intent(context, StepsCounterService::class.java)
        intent.putExtra("action", StepsCounterService.Action.STOP)

        Log.v(pluginName, "Stopping foreground service...")
        context.stopService(intent);
    }
}
