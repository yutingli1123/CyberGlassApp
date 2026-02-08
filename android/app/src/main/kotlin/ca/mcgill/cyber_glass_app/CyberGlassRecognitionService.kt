package ca.mcgill.cyber_glass_app

import android.content.Intent
import android.speech.RecognitionService
import android.speech.RecognitionService.Callback

class CyberGlassRecognitionService : RecognitionService() {
    override fun onStartListening(intent: Intent?, callback: Callback?) {
         // Start listening for speech
    }

    override fun onStopListening(callback: Callback?) {
         // Stop listening
    }

    override fun onCancel(callback: Callback?) {
         // Cancel listening
    }
}
