package com.tk_lck.supero

import android.graphics.Color
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import kotlin.collections.Map

internal class NativeAdFactoryExample(val layoutInflater: LayoutInflater) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView  {
        val adView = layoutInflater.inflate(R.layout.my_native_ad, null) as NativeAdView
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        headlineView.text = nativeAd.headline
        bodyView.text = nativeAd.body
        adView.setBackgroundColor(android.graphics.Color.rgb(242,243,245))
        adView.setNativeAd(nativeAd)
        adView.bodyView = bodyView
        adView.headlineView = headlineView
        return adView
    }
}