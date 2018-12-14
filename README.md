# Identical in-app-payments ANE for Android+iOS
In-app-payments ANE is the first Adobe AIR Native Extension which has made sure the Android and iOS in-app-billing work flows are identical so AIR developers won't be confused at all. While making these two completely different APIs are identical, we made sure that you will have access to all their features so you are not missing anything important.

You will be able to manage your in-app payments in the most efficient way with an identical AS3 API.

**Main Features:**
* Verifies the list of product IDs availability on Google and Apple servers.
* Gets the list of users' previous purchases. (they call it 'restoring' purchases in iOS)
* Supports consumable, permanent and subscription payment types.
* Returns purchase information + developer-specified string uppon a successful purchase process.
* Returns purchase signature on Android and you have access to purchase receipts on iOS.
* Supports iOS 11+ [in-app-purchase promotion feature](https://developer.apple.com/app-store/promoting-in-app-purchases/).
* iOS ParentalGate notifier.

[find the latest **asdoc** for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/package-detail.html)

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
**IMPORTANT:** to use this feature, the ANE MUST be initialized the soonest possible in your app. the best place for that is the Constructor function of your project's Document Class.
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
	
	<!-- dependency ANEs https://github.com/myflashlab/common-dependencies-ANE -->
	<extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
		
  </extensions>
-->
```

# Requirements 
* Android API 15+
* iOS SDK 9.0+
* AIR SDK 30+

# Commercial Version
https://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/

[![in-app-payments ANE](https://www.myflashlabs.com/wp-content/uploads/2015/12/product_adobe-air-ane-in-app-payments-2018-595x738.jpg)](https://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).