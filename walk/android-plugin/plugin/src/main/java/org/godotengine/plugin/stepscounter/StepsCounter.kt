package org.godotengine.plugin.stepscounter

import android.Manifest
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

class GodotAndroidPlugin(godot: Godot): GodotPlugin(godot) {
    companion object {
        @JvmStatic var showToast = false

        @JvmStatic val permissionsRequestCode = 12
        @JvmStatic val neededPermissions = arrayOf(
            Manifest.permission.ACTIVITY_RECOGNITION,
        )
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

    @UsedByGodot
    private fun hasPermission(permission: String): Boolean {
        if (this.activity == null || this.activity?.applicationContext == null) {
            Log.e(pluginName, "Plugin activity is null!")
            return false
        }

        var isAllowed = false
        this.activity?.applicationContext?.let {
            isAllowed = ContextCompat.checkSelfPermission(it, permission) == PackageManager.PERMISSION_GRANTED
            Log.v(pluginName, "Permission check for '$permission' -> " + if (isAllowed) "GRANTED" else "NOT_GRANTED")
        }
        return isAllowed
    }

    // Don't use this, use OS.request_permission() in godot because this one does not expose a
    // callback that will run on completion.
    @UsedByGodot
    private fun requestPermission(permission: String) {
        Log.v(pluginName, "Requesting permission for \"$permission\"...")

        // cannot use the new, strongly recommended Activity Result API (registerForActivityResult())
        // since we only have a pointer to Activity from Godot. Go through ActivityCompat,
        // which isn't perfect because the Activity implements onRequestPermissionsResult().
        ActivityCompat.requestPermissions(this.activity!!, arrayOf(permission), permissionsRequestCode)
    }

    // the intended permissions request flow is to check hasPermission first, then query this
    // command to determine if you should show an in context UI explaining to the user why you need
    // a specific permission, and lastly requestPermission() to let the user grant/deny.
    @UsedByGodot
    private fun shouldShowRequestPermissionRationale(permission: String): Boolean {
        val res = ActivityCompat.shouldShowRequestPermissionRationale(this.activity!!, permission)
        Log.v(pluginName, "Should we should permission request rationale for \"$permission...\" " + if (res) "YES" else "NO")
        return res
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
            for (perm in neededPermissions) {
                hasPermission(perm)
            }
        }
    }
}
