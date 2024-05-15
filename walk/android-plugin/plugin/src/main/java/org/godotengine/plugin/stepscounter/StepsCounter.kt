package org.godotengine.plugin.stepscounter

import android.Manifest
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

class GodotAndroidPlugin(godot: Godot): GodotPlugin(godot) {
    companion object {
        @JvmStatic val CODE_PERMISSIONS_GRANTED_= 1
        @JvmStatic val neededPermissions = arrayOf(
            Manifest.permission.ACTIVITY_RECOGNITION,
            Manifest.permission.ACCESS_FINE_LOCATION,
        )
    }

    override fun getPluginName() = BuildConfig.GODOT_PLUGIN_NAME

    @UsedByGodot
    private fun hasPermission(permission: String): Boolean {
        if (this.activity == null || this.activity?.applicationContext == null) {
            Log.w(pluginName, "[WARNING] Plugin activity is null!")
            return false
        }

        var isAllowed = false
        this.activity?.applicationContext?.let {
            isAllowed = ContextCompat.checkSelfPermission(it, permission) == PackageManager.PERMISSION_GRANTED
            Log.v(pluginName, "Permission check for '$permission' -> " + if (isAllowed) "GRANTED" else "NOT_GRANTED")
        }
        return isAllowed
    }

    @UsedByGodot
    private fun requestPermission(permission: String) {
        // TODO: implement me
    }

    /**
     * Provide this stub function for users to call to check if everything is loaded and working.
     */
    @UsedByGodot
    private fun healthCheck(showToast: Boolean) {
        runOnUiThread {
            val msg:String = getPluginName() + " successfully loaded!"
            if (showToast) {
                Toast.makeText(activity, msg, Toast.LENGTH_LONG).show()
            }
            Log.v(pluginName, msg)
            hasPermission(neededPermissions[0])
            hasPermission(neededPermissions[1])
        }
    }
}
