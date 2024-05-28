package org.godotengine.plugin.stepscounter

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class PermissionManager private constructor() {
    companion object {
        @JvmStatic val permissionsRequestCode = 12
        @JvmStatic val neededPermissions = arrayOf(
            Manifest.permission.ACTIVITY_RECOGNITION,
        )
        @JvmStatic val TAG = "PermissionManager"

        fun onPermissionsRequestResult(
            requestCode: Int,
            permissions: Array<out String>?,
            grantResults: IntArray?
        ) {
            val source = if (requestCode == permissionsRequestCode) {
                "OS.request_permission()"
            } else {
                "${BuildConfig.GODOT_PLUGIN_NAME}.requestPermission()"
            }

            if (permissions != null && grantResults != null) {
                Log.v(TAG, "Received permissions result from $source:")
            } else {
                Log.v(TAG, "Failure receiving permissions result from $source!")
                return
            }

            for (i in permissions.indices) {
                val granted = if (grantResults[i] == PackageManager.PERMISSION_GRANTED) "GRANTED" else "DENIED"
                Log.v(TAG, permissions[i] + ": $granted")
            }
        }

        fun hasPermission(context: Context, permission: String): Boolean {
            val isAllowed = ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
            Log.v(TAG, "Permission check for '$permission' -> " + if (isAllowed) "GRANTED" else "NOT_GRANTED")
            return isAllowed
        }

        fun shouldShowRequestPermissionRationale(activity: Activity, permission: String): Boolean {
            val res = ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
            Log.v(TAG, "Should request rationale for \"$permission\"? " + if (res) "YES" else "NO")
            return res
        }

        fun requestPermission(activity: Activity, permission: String) {
            Log.v(TAG, "Requesting permission for \"$permission\"...")

            // cannot use the new, strongly recommended Activity Result API (registerForActivityResult())
            // since we only have a pointer to Activity from Godot. Go through ActivityCompat,
            // which isn't perfect because the Activity implements onRequestPermissionsResult().
            ActivityCompat.requestPermissions(activity, arrayOf(permission),
                permissionsRequestCode
            )
        }
    }
}