package org.godotengine.plugin.stepscounter

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

context(Context)
class StepsCounterListener {
    companion object {
        @JvmStatic val TAG = StepsCounterListener::class.simpleName
    }

    private val sensorManager by lazy {
        getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }
    private val sensor: Sensor? by lazy {
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    }
    private var sensorListener: SensorEventListener? = null

    private var stepsSinceLastReboot: Long = 0
    private var stepsAccuracy: Int = -1

    public fun getSteps(): Long {
        return stepsSinceLastReboot
    }

    public fun getAccuracy(): Int {
        return stepsAccuracy
    }

    suspend fun registerListener(
        handleSensorChanged: (stepsSinceLastReboot: Long) -> Unit,
        handleAccuracyChanged: (accuracy: Int) -> Unit
    ) = suspendCancellableCoroutine { continuation ->
        Log.d(TAG, "Registering sensor listener...")

        sensorListener = object: SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                if (event == null) return

                stepsSinceLastReboot = event.values[0].toLong()
                Log.d(TAG, "Steps since last reboot: $stepsSinceLastReboot")
                handleSensorChanged(stepsSinceLastReboot)

                if (continuation.isActive) {
                    continuation.resume(stepsSinceLastReboot)
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                Log.d(TAG, "Accuracy changed to: $accuracy")
                stepsAccuracy = accuracy
                handleAccuracyChanged(accuracy)
            }
        }

        continuation.invokeOnCancellation {
            unregisterListener()
        }

        // note: calling this function multiple times will register multiple listeners
        // and thus will cause you to receive multiple callbacks for the same step count (need
        // to keep track in member state so we only register this once)
        val supportedAndEnabled = sensorManager.registerListener(sensorListener!!, sensor, SensorManager.SENSOR_DELAY_UI)
        Log.d(TAG, "Sensor listener registered: $supportedAndEnabled")
    }

    public fun unregisterListener() {
        Log.d(TAG, "Unregistering sensor listener...")
        if (sensorListener != null) {
            sensorManager.unregisterListener(sensorListener!!)
        }
    }
}