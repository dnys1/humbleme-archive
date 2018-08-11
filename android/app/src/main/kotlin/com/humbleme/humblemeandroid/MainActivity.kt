package com.humbleme.humblemeandroid

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import kotlin.collections.List
import kotlin.collections.ArrayList
import kotlin.collections.HashMap
import android.os.AsyncTask
import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.util.Log

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

import android.Manifest
import android.annotation.TargetApi
import android.content.pm.PackageManager
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.firebase.FirebaseException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthProvider
import com.google.firebase.firestore.FirebaseFirestore
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity(), OnMapReadyCallback {
    private val _permissionsChannel = "humbleme/permissions"
    private val _phoneNumberChannel = "humbleme/verifyPhoneNumber"

    private var _rationaleJustShown: Boolean = false
    private var _denialCount : Int = 0

    // Late initialization of variable allows for no error now
    private lateinit var _permissionsCallback: PermissionsCallback
    private lateinit var _contactsCallback : ContactsCallback
    private var _mVerificationID : String? = null
    private var _mResendToken : PhoneAuthProvider.ForceResendingToken? = null
    private val _contactsRequestID = PermissionType.CONTACTS.ordinal
    private val _locationRequestID = PermissionType.LOCATION_IN_USE.ordinal
    private val _storageRequestID = PermissionType.STORAGE.ordinal
    private var mMap: GoogleMap? = null
    private lateinit var mAuth : FirebaseAuth
    private lateinit var mFirestore : FirebaseFirestore


    override fun onMapReady(p0: GoogleMap?) {
        mMap = p0
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        mAuth = FirebaseAuth.getInstance()
        mFirestore = FirebaseFirestore.getInstance()

        MethodChannel(flutterView, _phoneNumberChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendVerificationCode" -> sendVerificationCode(call.arguments as String, result)
                "loginWithPhoneNumber" -> {
                    val args = call.arguments as ArrayList<*>
                    val verificationCode: String? = args[1] as String?
                    if (verificationCode != null) {
                        val verificationID : String? = if (_mVerificationID != null) _mVerificationID else args[0] as String?
                        if (verificationID != null) {
                            verifyUser(verificationID, verificationCode, null, result)
                        } else {
                            result.error("ERROR", null, "Incorrect credentials. Please try again.")
                        }
                    } else {
                        result.error("ERROR", null, "Incorrect credentials. Please try again.")
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterView, _permissionsChannel).setMethodCallHandler { call, result ->
            _permissionsCallback = object : PermissionsCallback {
                override fun granted() {
                    _rationaleJustShown = false
                    _denialCount = 0
                    result.success(PermissionState.GRANTED.ordinal)
                }

                override fun denied() {
                    _rationaleJustShown = false
                    _denialCount = 0
                    result.success(PermissionState.DENIED.ordinal)
                }

                override fun showRationale() {
                    _rationaleJustShown = true
                    result.success(PermissionState.SHOW_RATIONALE.ordinal)
                }

                override fun unknownState() {
                    _rationaleJustShown = false
                    _denialCount = 0
                    result.success(PermissionState.UNKNOWN.ordinal)
                }
            }
            @TargetApi(VERSION_CODES.CUPCAKE)
            _contactsCallback = object : ContactsCallback {
                override fun onSuccess(contacts: List<HashMap<String, String>>) {
                    result.success(contacts)
                }

                override fun onError() {
                    result.success(null)
                }
            }
            when (call.method) {
                "requestPermission" -> {
                    val type: Int = call.arguments as Int
                    val permission: PermissionType = PermissionType.values()[type];
                    when (permission) {
                        PermissionType.CONTACTS -> requestContacts()
                        PermissionType.LOCATION_IN_USE -> requestLocation()
                        PermissionType.STORAGE -> requestStorage()
                        else -> _permissionsCallback.unknownState()
                    }
                }
                "getPermissionState" -> {
                    val type: Int = call.arguments as Int
                    val permission: PermissionType = PermissionType.values()[type]
                    when (permission) {
                        PermissionType.CONTACTS -> statusContacts(result)
                        PermissionType.LOCATION_IN_USE -> statusLocation(result)
                        PermissionType.STORAGE -> statusStorage(result)
                        else -> _permissionsCallback.unknownState()
                    }
                }
                "getContacts" -> {
                    GetContactsTask(contentResolver, _contactsCallback).execute()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun sendVerificationCode(phoneNumber: String, result: MethodChannel.Result) {
        val _mCallbacks = object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
            // This callback will be invoked in two situations:
            // 1 - Instant verification. In some cases the phone number can be instantly
            //     verified without needing to send or enter a verification code.
            // 2 - Auto-retrieval. On some devices Google Play services can automatically
            //     detect the incoming verification SMS and perform verification without
            //     user action.
            override fun onVerificationCompleted(credential: PhoneAuthCredential?) {
                verifyUser(null, null, credential, result)
                result.success(null)
            }

            // This callback is invoked in an invalid request for verification is made,
            // for instance if the the phone number format is not valid.
            override fun onVerificationFailed(e: FirebaseException?) {
                result.error("ERROR", null, e?.localizedMessage)
            }

            // The SMS verification code has been sent to the provided phone number, we
            // now need to ask the user to enter the code and then construct a credential
            // by combining the code with a verification ID.
            override fun onCodeSent(verificationID: String?, token: PhoneAuthProvider.ForceResendingToken?) {
                _mVerificationID = verificationID
                _mResendToken = token

                result.success(verificationID)
            }
        }

        // Sends the verification code to the user's phone and fires one of the above callbacks
        PhoneAuthProvider.getInstance().verifyPhoneNumber(
                phoneNumber,
                60,
                TimeUnit.SECONDS,
                this,
                _mCallbacks
        )
    }

    private fun verifyUser(verificationID: String?, verificationCode: String?, credential: PhoneAuthCredential?, result: MethodChannel.Result) {
        val currentUser = mAuth.currentUser!!
        if (credential == null) {
            val newCredential = PhoneAuthProvider.getCredential(verificationID!!, verificationCode!!)
            currentUser.linkWithCredential(newCredential).addOnCompleteListener(this, fun (it) {
                if (it.isSuccessful) {
                    result.success(true)
                } else {
                    result.error("ERROR", null, "An unknown error occurred.")
                }
            })
        } else {
            currentUser.linkWithCredential(credential).addOnCompleteListener(this, fun (it) {
                if (it.isSuccessful) {
                    val updates = HashMap<String, Any>()
                    updates["phoneNumberVerified"] = true
                    mFirestore.collection("users").document(currentUser.uid).update(updates)
                } else {
                    result.error("ERROR", null, "An unknown error occurred.")
                }
            })
        }
    }

    private fun statusStorage(result: MethodChannel.Result) {
        if (_rationaleJustShown) {
            _permissionsCallback.unknownState()
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    _permissionsCallback.showRationale()
                } else {
                    _permissionsCallback.unknownState()
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    private fun requestStorage() {
        if (_rationaleJustShown) {
            ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.READ_EXTERNAL_STORAGE }, _storageRequestID)
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_EXTERNAL_STORAGE)) {
                    _permissionsCallback.showRationale()
                } else {
                    // No explanation needed, we can request the permission
                    ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.READ_EXTERNAL_STORAGE }, _storageRequestID)
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    private fun statusContacts(result: MethodChannel.Result) {
        if (_rationaleJustShown) {
            _permissionsCallback.unknownState()
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_CONTACTS)) {
                    _permissionsCallback.showRationale()
                } else {
                    _permissionsCallback.unknownState()
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    private fun requestContacts() {
        if (_rationaleJustShown) {
            ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.READ_CONTACTS }, _contactsRequestID)
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.READ_CONTACTS)) {
                    _permissionsCallback.showRationale()
                } else {
                    // No explanation needed, we can request the permission
                    ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.READ_CONTACTS }, _contactsRequestID)
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    private fun statusLocation(result: MethodChannel.Result) {
        if (_rationaleJustShown) {
            _permissionsCallback.unknownState()
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_COARSE_LOCATION)) {
                    _permissionsCallback.showRationale()
                } else {
                    _permissionsCallback.unknownState()
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    private fun requestLocation() {
        if (_rationaleJustShown) {
            ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.ACCESS_COARSE_LOCATION }, _locationRequestID)
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // Should we show an explanation
                if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_COARSE_LOCATION)) {
                    _permissionsCallback.showRationale()
                } else {
                    // No explanation needed, we can request the permission
                    ActivityCompat.requestPermissions(this, Array(1) { Manifest.permission.ACCESS_COARSE_LOCATION }, _locationRequestID)
                }
            } else {
                _permissionsCallback.granted()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?) {

        when (PermissionType.values()[requestCode]) {
            PermissionType.CONTACTS -> {
                // If request is cancelled, the result array is empty
                if (grantResults!!.count() > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    _permissionsCallback.granted()
                } else {
                    _denialCount++
                    if (_denialCount == 2) {
                        _permissionsCallback.denied()
                    } else {
                        _permissionsCallback.showRationale()
                    }
                }
            }
            PermissionType.LOCATION_IN_USE -> {
                if (grantResults!!.count() > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    _permissionsCallback.granted()
                } else {
                    _denialCount++
                    if (_denialCount == 2) {
                        _permissionsCallback.denied()
                    } else {
                        _permissionsCallback.showRationale()
                    }
                }
            }
            PermissionType.STORAGE -> {
                if (grantResults!!.count() > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    _permissionsCallback.granted()
                } else {
                    _denialCount++
                    if (_denialCount == 2) {
                        _permissionsCallback.denied()
                    } else {
                        _permissionsCallback.showRationale()
                    }
                }
            }
        }// reset to initial
        return
    }

    @TargetApi(VERSION_CODES.CUPCAKE)
    private class GetContactsTask(contentResolver: ContentResolver, contactsCallback: ContactsCallback) : AsyncTask<Void, Void, ArrayList<HashMap<String, String>>?>() {
        private val _contentResolver = contentResolver
        private var _contactsCallback = contactsCallback

        @TargetApi(VERSION_CODES.ECLAIR)
        override fun doInBackground(vararg params: Void?): ArrayList<HashMap<String, String>>? {
            try {
                val cr : ContentResolver = _contentResolver
                val uri : Uri = ContactsContract.Contacts.CONTENT_URI
                val projection : Array<String> = arrayOf(ContactsContract.Contacts._ID, ContactsContract.Contacts.DISPLAY_NAME_PRIMARY)
                val selection : String = ContactsContract.Contacts.HAS_PHONE_NUMBER + " = 1"
                val sortOrder : String = ContactsContract.Contacts.DISPLAY_NAME + " COLLATE LOCALIZED ASC"
                val contacts : ArrayList<HashMap<String, String>> = ArrayList()

                val users : Cursor = cr.query(uri, projection, selection, null, sortOrder)

                while (users.moveToNext()) {
                    val contact : HashMap<String,String> = HashMap()
                    val contactId : Int = users.getInt(users.getColumnIndex(ContactsContract.Contacts._ID))
                    val displayName : String = users.getString(users.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME))
                    var mobileNumber : String? = null

                    val contactNumbers : Cursor = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null,
                            ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = " + contactId, null, null)
                    while (contactNumbers.moveToNext()) {
                        val number : String = contactNumbers.getString(contactNumbers.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
                        val type : Int = contactNumbers.getInt(contactNumbers.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE))
                        when (type) {
                            ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE -> contact.put("MOBILE", number.orEmpty())
                        }
                    }
                    contactNumbers.close()

                    contact.put("NAME", displayName)
                    contacts.add(contact)
                }

                users.close()
                return contacts
            } catch (e : Exception) {
                Log.e("DEBUG", "Exception: $e")
            }
            return null
        }

        override fun onPostExecute(result: ArrayList<HashMap<String, String>>?) {
            if (result == null) {
                _contactsCallback.onError()
            } else {
                _contactsCallback.onSuccess(result)
            }
        }
    }

    enum class PermissionState {
        GRANTED, DENIED, SHOW_RATIONALE, UNKNOWN
    }

    enum class PermissionType {
        CONTACTS, LOCATION_ALWAYS, LOCATION_IN_USE, NOTIFICATIONS, MICROPHONE, CAMERA, PHOTOS, REMINDERS, EVENTS, BLUETOOTH, MOTION, STORAGE
    }

    interface PermissionsCallback {
        fun granted()
        fun denied()
        fun showRationale()
        fun unknownState()
    }

    interface ContactsCallback {
        fun onSuccess(contacts : List<HashMap<String,String>>)
        fun onError()
    }
}
