# Identical in-app-payments ANE for Android+iOS
In-app-payments ANE is the first Adobe AIR Native Extension which has made sure the Android and iOS in-app-billing work flows are identical so AIR developers won't be confused. While making these two completely different APIs identical, we made sure that you will have access to all their features so you are not missing anything.

You will be able to manage your in-app payments in the most efficient way with an identical AS3 API.

**Main Features:**
* Verifies the list of product IDs availability on Google and Apple servers.
* Gets the list of users' previous purchases. (Known as 'restoring' purchases in iOS)
* Supports consumable, permanent and subscription payment types.
* Returns purchase signature on Android and you have access to purchase receipts on iOS.
* Supports iOS 11+ [in-app-purchase promotion feature](https://developer.apple.com/app-store/promoting-in-app-purchases/).
* iOS ParentalGate notifier.
* Supports Android promo-purchases.
* Supports Android purchase acknowledgement.

[find the latest **asdoc** for this ANE here.](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/package-detail.html)

# How to test purchases in your app

On Android, you must create test users in your Google Play console and when running the app in your device, you must make sure that the test user introduced in your Google Play console is logged in on the device. In this case, all the payments will happen without real money.

On iOS, you must create sandbox test users from your iTunesConnect panel and when testing the app, you must login with that test account appleID. However, you should notice that permenant products on iOS, when purchased, cannot be consumed so if you want to test them again, you must create new sandbox/test users.

# AIR Usage
For the complete AS3 code usage, see the [demo project here](https://github.com/myflashlab/inAppPayments-ANE/blob/master/AIR/src/Main.as).

```actionscript
import com.myflashlab.air.extensions.billing.*;

// The first step is to setup your Google in-app products and iOS products in your Google 
// Play and iTunes Connect consoles. there are a lot of tutorials on the web talking about 
// how you can setup your consoles with the product IDs and using this extension makes no 
// different on that part. So, after you finished setting up your console, here's how you do 
// the coding part in AIR.

/*
	IMPORTANT: you must initialize this ANE as soon as possible in your app.
	The best place is the first line of your document-class's constructor function.
*/


// initialize the extension by passing in the product IDs and finally a callback function so 
// you will know when the initialization process finishes.
Billing.init(
	[Array of Android in-app product IDs], // or pass null if you don't use these
	[Array of Android subscription IDs], // or pass null if you don't use these
	[Array of iOS in-app product IDs], // or pass null if you don't use these
	[Array of iOS subscription IDs], // or pass null if you don't use these
	onInitResult);

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
		for (var i:int = 0; i < Billing.products.length; i++)
		{
			trace("\t productId = " + 	Billing.products[i].productId);
			trace("\t title = " + 		Billing.products[i].title);
			trace("\t description = " + Billing.products[i].description);
			trace("\t price = " + 		Billing.products[i].price);
			trace("\t currency = " + 	Billing.products[i].currency);
		}
	}
		
	/*
		only when the ANE is initialized, you must call other methods.
		the main methods of this ANE are: getPurchases, doPayment
	*/
	
	// Use getPurchases to connect to Google/Apple servers and restore the 
	// list of previously purchased products. Notice that consumable products 
	// are never saved so you should not expect to receive them with this method.
	Billing.getPurchases(onGetPurchasesResult);
	
	// To start a payment flow, use the doPayment method and pass in the type of payment, 
	// the productID and an optional String as accountID and finally the callback function to get 
	// the result of the payment.
	Billing.doPayment(BillingType.CONSUMABLE, "productId", null, onPurchaseResult);
}

private function onGetPurchasesResult($purchases:Vector.<Purchase>):void
{
	if ($purchases) // means we have successfully connected the server.
	{
		if ($purchases.length > 0)
		{
			for (var i:int = 0; i < $purchases.length; i++)
			{
				trace("purchaseData.orderId = " +			$purchases[i].orderId);
				trace("purchaseData.productId = " +			$purchases[i].productId);
				trace("purchaseData.purchaseState = " +		$purchases[i].purchaseState);
				trace("purchaseData.purchaseTime = " +		$purchases[i].purchaseTime);
				trace("purchaseData.purchaseToken = " +		$purchases[i].purchaseToken);

				if(Billing.os == Billing.ANDROID)
				{
					trace("purchaseData.autoRenewing = " +	 $purchases[i].autoRenewing);
					trace("purchaseData.signature = " +		 $purchases[i].signature);
					trace("purchaseData.isAcknowledged = " + $purchases[i].isAcknowledged);
					trace("verifyAndroidPurchaseLocally: " + Billing.verifyAndroidPurchaseLocally($purchases[i]));
				}
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

private function onPurchaseResult($status:int, $purchase:Purchase, $msg:String, $wasConsumed:Boolean):void
{
	trace("\n purchase was successful? " + Boolean($status));
	
	if ($msg == Billing.ALREADY_OWNED_ITEM || $msg == Billing.NOT_FOUND_ITEM)
	{
		trace($msg);
	}
	else
	{
		trace("purchase result message = " + $msg);
	}
	
	if ($purchase)
	{
		if($purchase.billingType == BillingType.CONSUMABLE)
		{
			trace("purchase was consumed? " + $wasConsumed);
			
			if(!$wasConsumed)
			{
				trace("There's been a problem in consuming this Android product. mark it and consume it manually now...");
				Billing.forceConsume($purchase.purchaseToken, onForceConsumeResult);
			}
		}

		trace("$purchase.billingType = " +			$purchase.billingType);
		trace("$purchase.orderId = " +				$purchase.orderId);
		trace("$purchase.productId = " +			$purchase.productId);
		trace("$purchase.purchaseState = " +		$purchase.purchaseState);
		trace("$purchase.purchaseTime = " +			$purchase.purchaseTime);
		trace("$purchase.purchaseToken = " +		$purchase.purchaseToken);
		
		if(OverrideAir.os == OverrideAir.ANDROID)
		{
			trace("$purchase.autoRenewing = " +		$purchase.autoRenewing);
			trace("$purchase.signature = " +		$purchase.signature);
			trace("$purchase.isAcknowledged = " +	$purchase.isAcknowledged);
			trace("$purchase.rawData = " +			$purchase.rawData);

			// it is recommended to verify purchases on your server. but yet, you can do it on the app also.
			// before calling this method however, you should have set the Billing.publicKey property
			trace("verifyAndroidPurchaseLocally: "+ Billing.verifyAndroidPurchaseLocally($purchase));
		}
	}
}
```
# AIR Usage - Consume a purchase on Android
```actionscript
// when a purchase is successful, you will have access to $purchase.purchaseToken. you should use this
// string to force consume a purchase on Android. in iOS, you cannot consume purchases manually!
Billing.forceConsume("purchaseToken String", onForceConsumeResult);
function onForceConsumeResult($result:Boolean):void
{
	if($result)
	{
		trace("your purchase has been consumed successfully");
	}
	else
	{
		trace("something went wrong! You may try again.");
	}
}
```
# AIR Usage - Acknowledge a purchase on Android
```actionscript
// On Android, you must always acknowledge a purchase when results are returned.
// A successfull purchase will return the purchase token, you must pass it to the
// acknowledgePurchase method.
// consumable purchases are automatically acknowledged by the ANE but for Permenant 
// and autoRenewal purchases, you must use the acknowledgePurchase method.

Billing.acknowledgePurchase(purchaseToken, function ($error:String):void
{
	if($error) trace($error);
	else trace("onAcknowledgePurchase success");
});
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
		// we cannot determine the "billingType" on promo purchases!
		// It's your job to name your productId in a way so you will know this.
		trace("$data.orderId = " + 		e.purchase.orderId);
		trace("$data.productId = " +		e.purchase.productId);
		trace("$data.purchaseState = " +	e.purchase.purchaseState);
		trace("$data.purchaseTime = " +		e.purchase.purchaseTime);
		trace("$data.purchaseToken = " +	e.purchase.purchaseToken);
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

# Promo purcases on Android
You can [create promotional codes](https://support.google.com/googleplay/android-developer/answer/6321495?hl=en&ref_topic=7071529) and send them out to your users. Users can redeem these codes inside GooglePlay app or you can take users there by calling ```Billing.redeem()``` method. When users submit the code, they will be returned to your app. In your app, you must always check ```Billing.getPurchases``` when the app resumes so you would know if a promo-purchase has happened or not.

```actionscript
NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);

private function handleActivate(e:Event):void
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
		<activity
			android:name="com.android.billingclient.api.ProxyBillingActivity"
			android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
			android:theme="@android:style/Theme.Translucent.NoTitleBar"/>
		
	</application>
</manifest>



<!--
FOR iOS:
-->
<key>MinimumOSVersion</key>
<string>10.0</string>
	
	
	
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
* Android API 19+
* iOS SDK 10.0+
* AIR SDK 30+

# Commercial Version
https://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/

[![in-app-payments ANE](https://www.myflashlabs.com/wp-content/uploads/2015/12/product_adobe-air-ane-in-app-payments-2018-595x738.jpg)](https://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).