package com.exchangily.wallet;
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import android.os.Bundle
import androidx.annotation.NonNull
import com.walletconnect.sign.client.Sign
import com.walletconnect.sign.client.SignClient
import android.app.Application

class  MainActivity: FlutterActivity(), Application(){
    
    // override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    //     GeneratedPluginRegistrant.registerWith(flutterEngine)
    // }

    private val CHANNEL ="com.exchangily.wallet/walletconnectsign"
    private val TESTCHANNEL = "com.exchangily.wallet/connectiontest"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(<Application>,flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TESTCHANNEL).setMethodCallHandler {
            call, result -> 
            if(call.method == "test"){
                result.success("Test passed")
            }
            
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(<Application>, savedInstanceState)

        GeneratedPluginRegister.registerGeneratedPlugins(FlutterEngine(this@MainActivity))
       
        val signChannel = MethodChannel(flutterEngine?.dartExecutor, CHANNEL)
        signChannel.setMethodCallHandler { call, result ->
            when (call.method){
                "sign" -> {
                    val a = call.argument<String>("data")
                    if(call.method == "sign"){
                        
                        // val appMetaData = Sign.Model.AppMetaData(
                        //     name = "Wallet Name",
                        //     description = "Wallet Description",
                        //     url = "Wallet Url",
                        //     icons = listOf("https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media")
                        //     )
                            
                         val connectionType = Sign.ConnectionType.AUTOMATIC
                            // or Sign.ConnectionType.MANUAL
                            val initString = Sign.Params.Init(
                                application = application,
                                relayServerUrl = "wss://testme.ca?projectId=123",
                                appMetaData = appMetaData,
                                connectionType = connectionType
                                //TODO: register at https://walletconnect.com/register to get a project ID
                            
                                )
                           
                                   
                                    SignClient.initialize(initString) { error ->
                                        //Log.e(tag(this), error.throwable.stackTraceToString())
                                        result.success("Test Failed: " +error.throwable.stackTraceToString())
                                    }
                    }
                }
              }
         }
    }

}