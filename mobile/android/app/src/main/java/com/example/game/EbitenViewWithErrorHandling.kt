package com.example.game

import android.content.Context
import android.util.AttributeSet
import com.example.game.mobile.EbitenView
import java.lang.Exception

internal class EbitenViewWithErrorHandling : EbitenView {
    constructor(context: Context?) : super(context) {}
    constructor(context: Context?, attributeSet: AttributeSet?) : super(context, attributeSet) {}

    override fun onErrorOnGameUpdate(e: Exception) {
        // You can define your own error handling e.g., using Crashlytics.
        // e.g., Crashlytics.logException(e);
        super.onErrorOnGameUpdate(e)
    }
}