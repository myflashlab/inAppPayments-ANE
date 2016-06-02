# Identical in-app-payments ANE V2.0.0 for Android+iOS
In-app-payments ANE is the first Adobe Air Native Extension which has made sure the Android and iOS in-app-billing work flows are identical so Air developers won't be confused at all. While making these two completely different APIs are identical, we made sure that you will have access to almost all their powers so you are not missing anything important.

You will be able to manage your in-app payments in the most efficient way with an identical AS3 API.

**Main Features:**
* Verifies the list of product IDs availability on Google and Apple servers.
* Gets the list of users' previous purchases. (they call it 'restoring' purchases in iOS)
* Supports consumable, permanent and subscription payment types.
* Returns purchase information + developer-specified string uppon a successful purchase process.

# asdoc
[find the latest asdoc for this ANE here.](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/billing/package-detail.html)

**NOTICE**: the demo ANE works only after you hit the "OK" button in the dialog which opens. in your tests make sure that you are NOT calling other ANE methods prior to hitting the "OK" button.
[Download the ANE](https://github.com/myflashlab/inAppPayments-ANE/tree/master/FD/lib)

# Air Usage
```actionscript
import com.myflashlab.air.extensions.billing.Billing;
import com.myflashlab.air.extensions.billing.BillingType;
import com.myflashlab.air.extensions.billing.Purchase;
import com.myflashlab.air.extensions.billing.Product;

// The first step is to setup your Google in-app products and iOS products in your Google Play and iTunes Connect consoles.
// there are a lot of tutorials on the web talking about how you can setup your consoles with the product IDs and using this
// extension makes no different on that part. So, after you finished setting up your console, here's how you do the coding part.

// omit this line or set to false when you're ready to make a release version of your app. [When developing, make sure you are setting this to true]
Billing.IS_DEBUG_MODE = true;

// initialize the extension by passing in the product IDs and finally a callback function so you will know when the initialization process finishes.
Billing.init("Android KEY from Google Play Console", [Array of Android products], [Array of iOS products], callbackFunction);

private function onInitResult($status:int, $msg:String):void
{
	if (!Boolean($status))
	{
		// if $status is 0 it means that the initialization was not successful and this may happen because of many different reasons
		// which we have talked about them in the demo project sample codes. Please check FD/src/MainFinal.as file for more details.
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
	
	// so, we use getPurchases to connect to Google or Apple servers and restore the list of all previously purchased products.
	// Please note that consumable products are never saved so you should not expect to receive them with this method.
	Billing.getPurchases(onGetPurchasesResult);
	
	// To be able to make the Android and iOS APIs identical to the Air side and also to improve the extension performance 
	// and making it super dev-friendly, we decided to cache the purchase information. Considering this fact, you may need to
	// clear the local cache from time to time, for example when a user logouts from your app. Make sure to read the asdoc to know
	// more about this method and when is the best case senarios for clearing the cache.
	Billing.clearCache();
	
	// To make a payment, you can use the doPayment method and pass in the type of payment, the productID and an optional Payload
	// message and finally the callback function to get the result of the payment.
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
				trace("purchaseData.orderId = " + 			purchaseData.orderId);
				trace("purchaseData.productId = " +			purchaseData.productId);
				trace("purchaseData.purchaseState = " +		purchaseData.purchaseState);
				trace("purchaseData.purchaseTime = " +		purchaseData.purchaseTime);
				trace("purchaseData.purchaseToken = " +		purchaseData.purchaseToken);
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
		trace("$data.orderId = " + 				$data.orderId);
		trace("$data.developerPayload = " + 	$data.developerPayload);
		trace("$data.productId = " +			$data.productId);
		trace("$data.purchaseState = " +		$data.purchaseState);
		trace("$data.purchaseTime = " +			$data.purchaseTime);
		trace("$data.purchaseToken = " +		$data.purchaseToken);
		trace("----------------");
	}
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
		<activity android:name="com.doitflash.inAppBilling.utils.MyPurchase" android:theme="@style/Theme.Transparent" />
		
	</application>
</manifest>



<!--
FOR iOS:
-->
<key>MinimumOSVersion</key>
<string>7.1</string>
	
	
	
<!--
Embedding the ANE:
-->
  <extensions>
	<extensionID>com.myflashlab.air.extensions.billing</extensionID>
  </extensions>
-->
```

# Requirements 
1. Android API 15 or higher
2. iOS SDK 7.1 or higher

# Commercial Version
http://www.myflashlabs.com/product/in-app-purchase-ane-adobe-air-native-extension/

![in-app-payments ANE](http://www.myflashlabs.com/wp-content/uploads/2015/12/product_adobe-air-ane-in-app-payments-595x738.jpg)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Changelog
*May 16, 2016 - V2.0.0*
* Added ```Billing.products``` property which will return an Array of ```Product``` objects containing SKU details about the products you have created on Apple or Google consoles
* Added ```Billing.forceConsume("productId", onResultFunction);``` method so you can force consume purchased products on the Android side

*Apr 15, 2016 - V1.0.2*
* Fixed a quick bug described here: https://github.com/myflashlab/inAppPayments-ANE/issues/5

*Apr 02, 2016 - V1.0.1*
* Fixed a quick bug described here: https://github.com/myflashlab/inAppPayments-ANE/issues/4

*Jan 27, 2016 - V1.0*
* beginning of the journey!
