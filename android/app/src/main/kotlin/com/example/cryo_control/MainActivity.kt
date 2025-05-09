package com.example.cryo_control

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.cryo_control/bluetooth"
    private val uuid: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private var socket: BluetoothSocket? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBluetoothEnabled" -> {
                    if (bluetoothAdapter == null) {
                        result.error("NO_ADAPTER", "Bluetooth not supported", null)
                    } else {
                        result.success(bluetoothAdapter.isEnabled)
                    }
                }

                "connectToDevice" -> {
                    val address = call.argument<String>("address")
                    if (bluetoothAdapter?.isEnabled != true) {
                        result.error("BT_OFF", "Bluetooth is off or not supported", null)
                        return@setMethodCallHandler
                    }
                    if (address.isNullOrEmpty()) {
                        result.error("NO_ADDRESS", "Device address is missing", null)
                        return@setMethodCallHandler
                    }

                    // Perform connect off the main thread
                    Thread {
                        try {
                            val device: BluetoothDevice = bluetoothAdapter.getRemoteDevice(address)
                            bluetoothAdapter.cancelDiscovery()
                            socket = device.createRfcommSocketToServiceRecord(uuid)
                            socket!!.connect()
                            result.success(true)
                        } catch (e: IOException) {
                            result.error("CONN_ERROR", "Connection failed: ${e.message}", null)
                        }
                    }.start()
                }

                "disconnect" -> {
                    try {
                        socket?.close()
                        socket = null
                        result.success(true)
                    } catch (e: IOException) {
                        result.error("DISC_ERROR", "Disconnect failed: ${e.message}", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
