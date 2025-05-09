package com.example.cryo_control

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.*

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.example.cryo_control/bluetooth"
    private val EVENT_CHANNEL = "com.example.cryo_control/bluetooth_data"
    private val uuid: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    private var socket: BluetoothSocket? = null
    private var outputStream: OutputStream? = null
    private var inputStream: InputStream? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
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
                        Thread {
                            try {
                                val device: BluetoothDevice = bluetoothAdapter.getRemoteDevice(address)
                                bluetoothAdapter.cancelDiscovery()
                                socket = device.createRfcommSocketToServiceRecord(uuid)
                                socket!!.connect()
                                outputStream = socket!!.outputStream
                                inputStream = socket!!.inputStream
                                result.success(true)
                            } catch (e: IOException) {
                                result.error("CONN_ERROR", "Connection failed: ${e.message}", null)
                            }
                        }.start()
                    }
                    "sendCommand" -> {
                        val command = call.argument<String>("command")
                        if (command.isNullOrEmpty()) {
                            result.error("NO_COMMAND", "Command is missing", null)
                            return@setMethodCallHandler
                        }
                        try {
                            outputStream?.write(command.toByteArray())
                            outputStream?.flush()
                            result.success(true)
                        } catch (e: IOException) {
                            result.error("SEND_ERROR", "Failed to send command: ${e.message}", null)
                        }
                    }
                    "disconnect" -> {
                        try {
                            socket?.close()
                            socket = null
                            outputStream = null
                            inputStream = null
                            result.success(true)
                        } catch (e: IOException) {
                            result.error("DISC_ERROR", "Disconnect failed: ${e.message}", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var thread: Thread? = null
                private var handler: Handler? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (events == null || inputStream == null) return
                    handler = Handler(Looper.getMainLooper())
                    thread = Thread {
                        try {
                            val reader = BufferedReader(InputStreamReader(inputStream))
                            while (true) {
                                val line = reader.readLine() ?: break
                                handler?.post { events.success(line) }
                            }
                        } catch (e: IOException) {
                            handler?.post { events.error("READ_ERROR", e.message, null) }
                        }
                    }
                    thread?.start()
                }

                override fun onCancel(arguments: Any?) {
                    thread?.interrupt()
                    thread = null
                    handler = null
                }
            })
    }
}
