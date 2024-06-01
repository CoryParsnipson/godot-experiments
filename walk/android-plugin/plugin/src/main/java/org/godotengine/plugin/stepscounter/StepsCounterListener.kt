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

    private suspend fun registerListener() = suspendCancellableCoroutine { continuation ->
        Log.d(TAG, "Registering sensor listener...")

        val listener: SensorEventListener by lazy {
            object: SensorEventListener {
                override fun onSensorChanged(event: SensorEvent?) {
                    if (event == null) return

                    val stepsSinceLastReboot = event.values[0].toLong()
                    Log.d(TAG, "Steps since last reboot: $stepsSinceLastReboot")
                    //emitSignal("on_step_counter_updated", stepsSinceLastReboot)

                    if (continuation.isActive) {
                        continuation.resume(stepsSinceLastReboot)
                    }
                }

                override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
                    Log.d(TAG, "Accuracy changed to: $accuracy")
                }
            }
        }

        // note: calling this function multiple times will register multiple listeners
        // and thus will cause you to receive multiple callbacks for the same step count (need
        // to keep track in member state so we only register this once)
        val supportedAndEnabled = sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_UI)
        Log.d(TAG, "Sensor listener registered: $supportedAndEnabled")
    }
}