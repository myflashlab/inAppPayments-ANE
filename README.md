# Identical in-app-payments ANE V2.3.0 for Android+iOS
In-app-payments ANE is the first Adobe AIR Native Extension which has made sure the Android and iOS in-app-billing work flows are identical so AIR developers won't be confused at all. While making these two completely different APIs are identical, we made sure that you will have access to all their features so you are not missing anything important.

You will be able to manage your in-app payments in the most efficient way with an identical AS3 API.

**Main Features:**
* Verifies the list of product IDs availability on Google and Apple servers.
* Gets the list of users' previous purchases. (they call it 'restoring' purchases in iOS)
* Supports consumable, permanent and subscription payment types.
* Returns purchase information + developer-specified string uppon a successful purchase process.
* Returns purchase signature on Android and you have access to purchase receipts on iOS.
* Supports iOS 11+ [in-app-purchase promotion feature](https://developer.apple.com/app-store/promoting-in-app-purchases/).

# asdoc
[find the latest asdoc for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/package-detail.html)

**NOTICE**: the demo ANE works only after you hit the "OK" button in the dialog which opens. in your tests make sure that you are NOT calling other ANE methods prior to hitting the "OK" button.
[Download the ANE](https://github.com/myflashlab/inAppPayments-ANE/tree/master/AIR/lib)

# AIR Usage
For the complete AS3 code usage, see the [demo project here](https://github.com/myflashlab/inAppPayments-ANE/blob/master/AIR/src/Main.as).

```actionscript
import com.myflashlab.air.extensions.billing.*;

// The first step is to setup your Google in-app products and iOS products in your Google 
// Play and iTunes Connect consoles. there are a lot of tutorials on the web talking about 
// how you can setup your consoles with the product IDs and using this extension makes no 
// different on that part. So, after you finished setting up your console, here's how you do 
// the coding part.

// omit this line or set to false when you're ready to make a release version of your app. 
// [When developing, make sure you are setting this to true]
Billing.IS_DEBUG_MODE = true;

/*
	IMPORTANT: you must initialize this ANE as soon as possible in your app.
	The best place is the first line of your document-class's constructor function.
*/


// initialize the extension by passing in the product IDs and finally a callback function so 
// you will know when the initialization process finishes.
Billing.init("Android KEY from Google Play Console", [Array of Android products], [Array of iOS products], onInitResult);

private function onInitResult($status:int, $msg:String):void
{
	trace("init was successful: " + Boolean($status));
	trace("init msg = " + $msg);
	
	if (!Boolean($status))
	{
		// if $status is 0 it means that the initialization was not successful and this may 
		// happen because of many different reasons which we have talked about them in the demo 
		// project sample codes. Please check AIR/src/Main.as file for more details.
		return;
	}
	else
	{
		// Here's the list of available/online products which you can make purchases on them:
		var availableProducts:Array = Billing.products;
		var currProduct:Product;
		for (var i:int = 0; i < availableProducts.length; i++) 
		{
			currProduct = availableProducts[i];
			trace("\t productId = " + 	currProduct.productId);
			trace("\t title = " + 		currProduct.title);
			trace("\t description = " + currProduct.description);
			trace("\t price = " + 		currProduct.price);
			trace("\t currency = " + 	currProduct.currency);
			trace("---------------------------------------");
		}
	}
		
	/*
		only when the ANE is initialized, you must call other methods.
		the main 3 methods of this API are: getPurchases, doPayment and clearCache
	*/
	
	// so, we use getPurchases to connect to Google or Apple servers and restore the 
	// list of all previously purchased products. Please note that consumable products 
	// are never saved so you should not expect to receive them with this method.
	Billing.getPurchases(onGetPurchasesResult);
	
	// To be able to make the Android and iOS APIs identical to the Air side and also 
	// to improve the extension performance and making it super dev-friendly, we decided 
	// to cache the purchase information. Considering this fact, you may need to clear the 
	// local cache from time to time, for example when a user logouts from your app. Make 
	// sure to read the asdoc to know more about this method and when is the best case 
	// senarios for clearing the cache.
	Billing.clearCache();
	
	// To make a payment, you can use the doPayment method and pass in the type of payment, 
	// the productID and an optional Payload message and finally the callback function to get 
	// the result of the payment.
	Billing.doPayment(BillingType.CONSUMABLE, "android.test.purchased", "Payload CONSUMABLE", onPurchaseResult);
}

private function onGetPurchasesResult($purchases:Array):void
{
	if ($purchases) // means we have successfully connected the server.
	{
		if ($purchases.length > 0)
		{
			var purchaseData:Purchase;
			var lng:int = $purchases.length;
			var i:int;
			
			for (i = 0; i < lng; i++)
			{
				purchaseData = $purchases[i];
				trace("----------------");
				trace("purchaseData.orderId = " + 		purchaseData.orderId);
				trace("purchaseData.productId = " +		purchaseData.productId);
				trace("purchaseData.purchaseState = " +		purchaseData.purchaseState);
				trace("purchaseData.purchaseTime = " +		purchaseData.purchaseTime);
				trace("purchaseData.purchaseToken = " +		purchaseData.purchaseToken);

				if(Billing.os == Billing.ANDROID)
				{
					trace("purchaseData.autoRenewing = " +		purchaseData.autoRenewing);
					trace("purchaseData.signature = " +		purchaseData.signature);
				}
				trace("----------------");
			}
		}
		else // if it's an empty Array, it means there are no purchase records for this user on the server.
		{
			trace("\n There are no purchase records for this user on Google or Apple servers.");
		}
	}
	else
	{
		trace("\n Error while trying to get the list of previously purchased records.")
	}
}

private function onPurchaseResult($status:int, $data:Purchase, $msg:String):void
{
	trace("\n purchase was successful? " + Boolean($status));
	
	if ($msg == Billing.ALREADY_OWNED_ITEM)
	{
		trace($msg);

		// on Android, you can consume items which are owned already using the Billing.forceConsume method
	}
	else if ($msg == Billing.NOT_FOUND_ITEM)
	{
		trace($msg);
	}
	else
	{
		trace("purchase result message = " + $msg);
	}
	
	if ($data)
	{
		trace("----------------");
		trace("$data.billingType = " + 			$data.billingType);
		trace("$data.orderId = " + 			$data.orderId);
		trace("$data.developerPayload = " + 		$data.developerPayload);
		trace("$data.productId = " +			$data.productId);
		trace("$data.purchaseState = " +		$data.purchaseState);
		trace("$data.purchaseTime = " +			$data.purchaseTime);
		trace("$data.purchaseToken = " +		$data.purchaseToken);

		if(Billing.os == Billing.ANDROID)
		{
			trace("$data.autoRenewing = " +		$data.autoRenewing);
			trace("$data.signature = " +		$data.signature);
		}
		trace("----------------");
	}
}
```
# AIR Usage - Consume a purchase on Android
```actionscript
Billing.forceConsume("android.test.purchased", onForceConsumeResult);
function onForceConsumeResult($result:Boolean):void
{
	if($result)
	{
		trace("your purchase has been consumed successfully");
		Billing.clearCache();
	}
	else
	{
		trace("something went wrong! You may try again.");
	}
}
```
# AIR Usage - iOS 11+ promotional purchases
```actionscript
// listen to possible promo purchase results on iOS 11+
// Add these listeners right after the Billing.init method.
Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_FAILED, onIosPromoPurchaseFailed);
Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_SUCCESS, onIosPromoPurchaseSuccess);

function onIosPromoPurchaseFailed(e:BillingEvent):void
{
	trace("onPromoPurchaseFailed: " + e.msg);
}

function onIosPromoPurchaseSuccess(e:BillingEvent):void
{
	trace("onPromoPurchase status: " + e.status);
	trace("onPromoPurchase msg: " + e.msg);
	
	if (e.purchase)
	{
		trace("----------------");
		// we cannot determine the "billingType" on promo purchases!
		// It's your job to name your productId in a way so you will know this.
		trace("$data.orderId = " + 		e.purchase.orderId);
		trace("$data.developerPayload = " + 	e.purchase.developerPayload); // is always empty on promo purchases
		trace("$data.productId = " +		e.purchase.productId);
		trace("$data.purchaseState = " +	e.purchase.purchaseState);
		trace("$data.purchaseTime = " +		e.purchase.purchaseTime);
		trace("$data.purchaseToken = " +	e.purchase.purchaseToken);
		trace("----------------");
		
		// If your promo purchase is not a consumable one, you surely expect to see it when
		// Billing.getPurchases(onGetPurchasesResult); is called, right?
		// to make sure you are seeing it, always clear cache when PROMO_PURCHASE_SUCCESS happens.
		
		// When you clear the cache, the ANE will try to get the purchase results fresh from app store.
		Billing.clearCache();
	}
}
```
# Test Promo purchases:
Before releasing your app, you certainly want to see how the promotional links work on your developing stage, right? To test that, simply build a link with the following format and email it to yourself. Open the email in your iOS 11+ device and click on the link. It will open your app and starts the purchase process.
```
itms-services://?action=purchaseIntent&bundleId=com.example.app&productIdentifier=yourProductId

replace com.example.app with your own app package name / bundle ID
replace yourProductId with your own product ID which you wish to promote
```
# Air .xml manifest
```xml
<!--
FOR ANDROID:
-->
<manifest android:installLocation="auto">
	
	<uses-permission android:name="android.permission.INTERNET" />
	
	<!-- required for billing extension -->
	<uses-permission android:name="com.android.vending.BILLING" />
	
	<application android:hardwareAccelerated="true" android:allowBackup="true">
		
		<!-- required for billing dialog -->
		<activity android:name="com.doitflash.inAppBilling.utils.MyPurchase" android:theme="@style/Theme.Transparent" />
		
	</application>
</manifest>



<!--
FOR iOS:
-->
<key>MinimumOSVersion</key>
<string>9.0</string>
	
	
	
<!--
Embedding the ANE:
-->
  <extensions>
  
	<extensionID>com.myflashlab.air.extensions.billing</extensionID>
	
	<!-- download the dependency ANEs from https://github.com/myflashlab/common-dependencies-ANE -->
	<extensionID>com.myflashlab.air.extensions.dependency.androidSupport</extensionID>
	<extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
		
  </extensions>
-->
```

# Requirements 
* This ANE is dependent on **androidSupport.ane** and **overrideAir.ane**. Download them from [here](https://github.com/myflashlab/common-dependencies-ANE).
* Android API 15 or higher
* iOS SDK 9.0 or higher
* AIR SDK 28+

# Commercial Version
http://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/

![in-app-payments ANE](http://www.myflashlabs.com/wp-content/uploads/2015/12/product_adobe-air-ane-in-app-payments-595x738.jpg)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Changelog
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

*Jan 27, 2016 - V1.0*
* beginning of the journey!
