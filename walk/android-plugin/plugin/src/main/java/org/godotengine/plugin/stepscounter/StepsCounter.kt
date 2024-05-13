package org.godotengine.plugin.stepscounter

import android.content.Context
import android.hardware.SensorManager
import android.util.Log
import android.widget.Toast
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

class GodotAndroidPlugin(godot: Godot): GodotPlugin(godot) {

    override fun getPluginName() = BuildConfig.GODOT_PLUGIN_NAME

    /**
     * Provide this stub function for users to call to check if everything is laoded and working.
     */
    @UsedByGodot
    private fun healthCheck(showToast: Boolean) {
        runOnUiThread {
            val msg:String = getPluginName() + " successfully loaded!"
            if (showToast) {
                Toast.makeText(activity, msg, Toast.LENGTH_LONG).show()
            }
            Log.v(pluginName, msg)
        }
    }
}
