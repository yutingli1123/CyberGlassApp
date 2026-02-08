package ca.mcgill.cyber_glass_app

import android.service.voice.VoiceInteractionService
import android.content.Intent

class CyberGlassVoiceInteractionService : VoiceInteractionService() {
    override fun onReady() {
        super.onReady()
        // Service is ready
    }
}
