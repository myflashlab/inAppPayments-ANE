In App Payments Adobe Air Native Extension

*Dec 1, 2019 - V4.0.0*
* Updated the latest Android billing library V2.0.3
* The ```rawData``` property in **Purchase** class is now public and accessible.
* Introduced a new property called ```isAcknowledged``` to the **Purchase** class.
* Introduced new method, ```Billing.acknowledgePurchase()```.
* **NOTICE:** On Android, whenever a purchase is made, you must acknowledge it. Failure to acknowledge a purchase will result in that purchase being refunded.
  * For ```BillingType.CONSUMABLE```, ANE will automatically uses the new Android method to acknowledge the purchase.
  * For ```BillingType.PERMANENT``` and ```BillingType.AUTO_RENEWAL```, you must call the ```Billing.acknowledgePurchase()``` method after the purchase result is returned.


*Aug 4, 2019 - V3.0.11*
* Added support for Android 64-bit arch.
* Supports iOS 10+
* Added ```originalOrderId``` property to the Purchase class. useful when restoring purchases on the iOS side.

*Apr 5, 2019 - V3.0.0*
* Rebuilt the Android side with the [new billing library V1.2.2](https://developer.android.com/google/play/billing/billing_overview) provided with Google.
* Google has decided to [remove the **developerPlayload**](https://issuetracker.google.com/issues/63381481) option so we removed it from the ANE also. 
* Removed the whole ```com.doitflash.inAppBilling.utils.MyPurchase``` activity and added the following to the manifest instead of it.

```xml
<activity
	android:name="com.android.billingclient.api.ProxyBillingActivity"
	android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
	android:theme="@android:style/Theme.Translucent.NoTitleBar"/>
```
* **Billing.IS_DEBUG_MODE** is removed.
* providing the Android Public key is no longer mandatory. in previous versions you had to pass the publickey when initializing the ANE but it's no longer necessary. The public key is only needed in your app if you wish to verify Android purchases in your app. if so, you should set it through **Billing.publicKey** and then use the **Billing.verifyAndroidPurchaseLocally(purchases)** method. However, verifying a purchase in your app is not recommended. You should consider verifying them on your server. For more information, read [Google docs](https://developer.android.com/google/play/billing/billing_library_overview#Verify-purchase).

```actionscript
Billing.publicKey = "Base64-encoded RSA public key found in your GooglePlay console > Development Tools > Services and APIs";
var result:Boolean = Billing.verifyAndroidPurchaseLocally($purchases);
```

* When initializing the ANE, you must put the subscriptions in a seperate Array. If you don't support subscriptions, you can simply pass null. The initialization of the ANE has been changed like below:

```actionScript
Billing.init(
	[	// Android in-app product IDs which you have already set in your Google Play console.
		"productId01",
		"productId02",
		"productId03"
	],
	[ 	// Android subscription IDs which you have already set in your Google Play console.
		"subsProductId01",
		"subsProductId02"
	],
	[	// iOS in-app product IDs which you have already set in your iTunes Connect.
		"consumable_productId01",
		"managed_productId02",
		"managed_productId03",
		"promoConsumable1"
	],
	[ // iOS subscription IDs which you have already set in your iTunes Connect.
		"auto_renewable_01"
	],
	onInitResult);

function onInitResult($status:int, $msg:String):void
{
	trace("init was successful: " + Boolean($status));
	trace("init msg = " + $msg);
}
```

* promo purchases are now supported on Android too. To make sure you are always checking for possible purchases being happen in GooglePlay app, you must call **Billing.getPurchases** whenever your app is resumed:

```actionscript
NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);

function handleActivate(e:Event):void
{
	/*
		On Android, purchases will be read from GooglePlay app and it is recommended
		to always check it when app is activated. This way, if the user has redeemed
		a promotion code, your app will know about it.
		
		To know about promo-purchases on iOS, you must listen to the event
		BillingEvent.PROMO_PURCHASE_SUCCESS
	*/

	if(OverrideAir.os == OverrideAir.ANDROID && Billing.isInitialized)
		Billing.getPurchases(onGetPurchasesResult);
}
```

* The property **developerPayload** is removed from class Purchase. This is [Google's decision](https://issuetracker.google.com/issues/63381481). On the iOS side, we never had developerPayload but we had to do some tricks in ANE to make it happen. Now that Android also decided to remove it like iOS, we also removed it from both sides.
* **Billing.products** returns ```Vector.<Product>``` instead of an Array.
* The callback function for method **Billing.getPurchases** returns ```Vector.<Purchase>``` instead of an Array.

```actionscript
function($purchases:Vector.<Purchase>):void
{
	//$purchases: If null, it means there's been a problem in retriving the list of purchases from server.
	// if not null, but $purchases.length is 0, it means that there are no purchase records for this user on server
}
```

* The callback function for method **Billing.doPayment** now has a new parameter ```$wasConsumed:Boolean```.

```actionscript
function onPurchaseResult($status:int, $purchase:Purchase, $msg:String, $wasConsumed:Boolean):void
{
	//$status: if 1, it means that the purchase has been made successfully. 0 if otherwise.
	//$purchase: will be non-null if the purchase was successful.
	//$msg: a string representing the purchase result.
	//$wasConsumed: true if the purchase has been consumed already. This is meaningless when dealing with subscriptions

	/*
	IMPORTANT:
	Unlike iOS which you could create consumable products inside iTunesConnect, in Android you
	can only create managed products. This means that native devs will always need to manually consume
	their products. To make your job easier and make sure the Android and iOS sides work similar to each
	other on this ANE, we are consuming the purchases on Android automatically (if you have set
	BillingType.CONSUMABLE in the doPayment method).
	
	However, it is possible, that due to internet connection or any other reason, the process fails. So
	your Android consumable item will be purchased but not consumed! When this happens, you must
	forceConsume the item yourself. To know if this problem has happened, all you have to do is to
	check if the $wasConsumed param is true or not. and if it's false, call forceConsume on it.
	
	This problem might happen on Android side only. on iOS, it will be fine because the product is marked
	consumable by iTunesConnect and will be consumed without ANE's help.
}
```

* When starting a new payment flow, instead of passing the developerPayload, you have the option to pass **AccountId** or pass null.

```actionscript
Billing.doPayment(
	BillingType.CONSUMABLE,
	"productId01",
	null,
	onPurchaseResult);

/*
	Specify an optional obfuscated string that is uniquely associated with the user's account in your app. 
	
	If you pass this value, Google/Apple can use it to detect irregular activity, such as many
 	devices making purchases on the same account in a short period of time. Do not use the developer ID or the
 	user's Google ID for this field. In addition, this field should not contain the user's ID in cleartext.

 	We recommend that you use a one-way hash to generate a string from the user's ID and store the hashed string in
 	this field.
*/
```

* The ```Billing.forceConsume``` method works with **purchaseToken** from now on instead of passing the productId. When a purchase happens or when you call **Billing.getPurchases** to retrive old purchases, Every purchase has a String purchaseToken property. you must pass this string to the Billing.forceConsume method.

```actionscript
Billing.forceConsume(purchase.purchaseToken, onForceConsumeResult);
```

* Added new method [Billing.redeem()](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#redeem())
* Added new method [Billing.replaceSubscription()](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#replaceSubscription())
* Added new method [Billing.isFeatureSupported()](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#isFeatureSupported())
* Added new method [Billing.priceChangeConfirmation()](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#priceChangeConfirmation())
* Added new method [Billing.verifyAndroidPurchaseLocally()](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#verifyAndroidPurchaseLocally())
* Added new property [Billing.CHILD_DIRECTED](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#CHILD_DIRECTED)
* Added new property [Billing.UNDER_AGE_OF_CONSENT](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#UNDER_AGE_OF_CONSENT)
* Added new property [Billing.isInitialized](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/Billing.html#isInitialized)
* The method ```Billing.clearCache``` is deprecated and will be removed in future versions. The ANE will now clear the cache whenever is necessary so you don't have to do it manually.

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