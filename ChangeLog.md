In App Payments Adobe Air Native Extension

*Nov 18, 2018 - V2.5.4*
* Works with OverrideAir ANE V5.6.1 or higher
* Works with ANELAB V1.1.26 or higher
* Added support for iOS [ParentalGate](https://github.com/myflashlab/inAppPayments-ANE/issues/84)
```actionscript
// set this to true if your app targets kids. (iOS). MUST BE SET BEFORE INITIALIZING THE ANE
Billing.PARENTAL_GATE = true;

... init the ANE code ...

// This will be called before purchase flow begins 
Billing.listener.addEventListener(BillingEvent.PARENT_PERMISSION_REQUIRED, onParentPermissionRequired);

private function onParentPermissionRequired(e:BillingEvent):void
{
	trace("onParentPermissionRequired: " + e.msg);
	
	// this will be called on iOS; ONLY if you have set Billing.PARENTAL_GATE = true;
	// When iOS 11+ iTunes promo purchase is used, the app starts and the purchase flow begins automatically.
	// This is normal for most apps but if your app is targeted for kids, your app will be rejected if the
	// purchase flow starts automatically. Apple requires you to do some parental-gate before any purchase flow
	// begins.
	
	// When you receive this event, you must do some parental-gate and if it was successful, you must tell the
	// ANE to continue the purchase flow. https://developer.apple.com/app-store/parental-gates/
	
	Billing.continueThePreventedPurchaseFlow();
}
```

*Sep 23, 2018 - V2.5.2*
* Removed androidSupport dependency

*May 23, 2018 - V2.5.1*
* fixed [issue 76](https://github.com/myflashlab/inAppPayments-ANE/issues/76)

*May 9, 2018 - V2.5.0*
* fixed [issue 69](https://github.com/myflashlab/inAppPayments-ANE/issues/69)
* fixed [issue 66](https://github.com/myflashlab/inAppPayments-ANE/issues/66)

*Dec 15, 2017 - V2.3.0*
* updated with the latest androidSupport and overrideAir dependencies.
* synced to be used with the [ANE-LAB software](https://github.com/myflashlab/ANE-LAB/).
* Added ```Billing.iOSReceipt``` property.
* Added **autoRenewing** and **signature** properties to the ```Purchase``` class which are relevant for the Android side only.
* Added support for iOS 11+ promo purchases through app store. You need to add the following listeners right after initializing the ANE.
```actionscript
// listen to possible promo purchase results on iOS 11+
Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_FAILED, onIosPromoPurchaseFailed);
Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_SUCCESS, onIosPromoPurchaseSuccess);
```
* min iOS version to support this ANE is 9.0
* you need to compile your project with AIR SDK 28.0+

*Aug 05, 2017 - V2.2.2*
* Fixed issue [21](https://github.com/myflashlab/inAppPayments-ANE/issues/21)
* Fixed issue [31](https://github.com/myflashlab/inAppPayments-ANE/issues/31)

*Jun 24, 2017 - V2.2.1*
* Fixed issue [40](https://github.com/myflashlab/inAppPayments-ANE/issues/40)

*Mar 19, 2017 - V2.2.0*
* Even if you are building for iOS only, you still need to include the following ANE as the dependency ```overrideAir.ane V4.0.0```
* Min iOS version to support this ANE will be iOS 8.0+ from now on.
* optimized for iTunes missing title problem described at [issue 32](https://github.com/myflashlab/inAppPayments-ANE/issues/32)

*Nov 09, 2016 - V2.1.0*
* Optimized for Android manual permissions if you are targeting AIR SDK 24+
* From now on, this ANE will depend on androidSupport.ane and overrideAir.ane on the Android side

*May 16, 2016 - V2.0.0*
* Added ```Billing.products``` property which will return an Array of ```Product``` objects containing SKU details about the products you have created on Apple or Google consoles
* Added ```Billing.forceConsume("productId", onResultFunction);``` method so you can force consume purchased products on the Android side

*Apr 15, 2016 - V1.0.2*
* Fixed a quick bug described here: https://github.com/myflashlab/inAppPayments-ANE/issues/5

*Apr 02, 2016 - V1.0.1*
* Fixed a quick bug described here: https://github.com/myflashlab/inAppPayments-ANE/issues/4

*Jan 27, 2016 - V1.0.0*
* beginning of the journey!