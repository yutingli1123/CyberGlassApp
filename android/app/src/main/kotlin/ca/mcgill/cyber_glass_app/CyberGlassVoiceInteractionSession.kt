package ca.mcgill.cyber_glass_app

import android.app.assist.AssistContent
import android.app.assist.AssistStructure
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.service.voice.VoiceInteractionSession
import android.util.Log

class CyberGlassVoiceInteractionSession(context: Context) : VoiceInteractionSession(context) {

    override fun onCreate() {
        super.onCreate()
        // Initialize session
    }

    override fun onShow(args: Bundle?, showFlags: Int) {
        super.onShow(args, showFlags)
        
        try {
            // Open the main activity
            val intent = Intent(context, MainActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // Use startActivity instead of startVoiceActivity for standard app launch
            context.startActivity(intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onHide() {
        super.onHide()
        // Handle when UI is hidden
    }

    override fun onHandleAssist(
        data: Bundle?,
        structure: AssistStructure?,
        content: AssistContent?
    ) {
        super.onHandleAssist(data, structure, content)
        // Handle context data from the app that invoked the assistant
    }
}
