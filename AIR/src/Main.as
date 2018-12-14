package 
{
	import com.myflashlab.air.extensions.billing.*;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.InvokeEvent;

	import com.myflashlab.air.extensions.dependency.OverrideAir;
	
	import com.doitflash.text.modules.MySprite;
	import com.doitflash.starling.utils.list.List;
	import com.doitflash.consts.Direction;
	import com.doitflash.consts.Orientation;
	import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
	
	import com.luaye.console.C;
	
	/**
	 * ...
	 * @author Hadi Tavakoli - 1/11/2016 3:13 PM
	 */
	public class Main extends Sprite 
	{
		private const BTN_WIDTH:Number = 150;
		private const BTN_HEIGHT:Number = 60;
		private const BTN_SPACE:Number = 2;
		private var _txt:TextField;
		private var _body:Sprite;
		private var _list:List;
		private var _numRows:int = 1;
		
		public function Main():void 
		{
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			C.startOnStage(this, "`");
			C.commandLine = false;
			C.commandLineAllowed = false;
			C.x = 20;
			C.width = 250;
			C.height = 150;
			C.strongRef = true;
			C.visible = true;
			C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
			
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.antiAliasType = AntiAliasType.ADVANCED;
			_txt.multiline = true;
			_txt.wordWrap = true;
			_txt.embedFonts = false;
			_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>Identical (iOS+Android) in-app-payments ANE V"+Billing.VERSION+"</b></font>";
			_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			this.addChild(_txt);
			
			_body = new Sprite();
			this.addChild(_body);
			
			_list = new List();
			_list.holder = _body;
			_list.itemsHolder = new Sprite();
			_list.orientation = Orientation.VERTICAL;
			_list.hDirection = Direction.LEFT_TO_RIGHT;
			_list.vDirection = Direction.TOP_TO_BOTTOM;
			_list.space = BTN_SPACE;
			
			init();
		}
		
		private function onInvoke(e:InvokeEvent):void
		{
			NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
		}
		
		private function handleActivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(e:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		
		private function handleKeys(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
			{
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
			}
		}
		
		private function onResize(e:*=null):void
		{
			if (_txt)
			{
				_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				
				C.x = 0;
				C.y = _txt.y + _txt.height + 0;
				C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
				C.height = 600 * (1 / DeviceInfo.dpiScaleMultiplier);
			}
			
			if (_list)
			{
				_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
				_list.row = _numRows;
				_list.itemArrange();
			}
			
			if (_body)
			{
				_body.y = stage.stageHeight - _body.height;
			}
		}
		
		private function init(e:Event=null):void
		{
			// Remove OverrideAir debugger in production builds
			OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void
			{
				trace($ane+" ("+$class+") "+$msg);
			});
			
			C.log("ANE is initializing and checking if everything is ok with your app/device/productIDs/etc...");
			C.log("Please wait... \n");
			
			/**
			 * Android products built in Google Play console:
			 * test01 > Managed product
			 * test02 > Managed product
			 * test03 > Monthly subscription
			 * test04 > Yearly subscription
			 * 
			 * iOS products built in itunes Connect:
			 * inappbilling_auto_renewable_one	> Automatically Renewable Subscription
			 * inappbilling_consumable_one		> Consumable
			 * inappbilling_managed_one			> Non-Consumable
			 */
			
			// omit this line or set to false when you're ready to make a release version of your app.
			// ONLY When developing your app, make sure you are setting this to true.
			Billing.IS_DEBUG_MODE = true;
			
			// set this to true only if your app targets kids. (iOS)
			//Billing.PARENTAL_GATE = true;

			var androidKey:String = "android key copied from your Google Play console...";
			
			Billing.init(androidKey,
					
					[	// Android product IDs which you have already set in your Google Play console.
						"test01", // 1.00 managed product
						"test02", // $1.10 managed product
						"test03", // $1.10 monthly subscription
						"test04", // $1.31 yearly subscription
						"test05", // $47 expensive managed product
						"test06" // $10 managed product
					],
					[	// iOS product IDs which you have already set in your iTunes Connect.
						"inappbilling_auto_renewable_one",
						"inappbilling_consumable_one",
						"inappbilling_managed_one",
						"inappbilling_managed_two",
						"inappbilling_managed_three",
						"inappbilling_managed_four",
						"inappbilling_managed_five",
						"promoConsumable1"
					],
					
					onInitResult);
			
			// listen to possible promo purchase results on iOS 11+
			Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_FAILED, onIosPromoPurchaseFailed);
			Billing.listener.addEventListener(BillingEvent.PROMO_PURCHASE_SUCCESS, onIosPromoPurchaseSuccess);
			Billing.listener.addEventListener(BillingEvent.PARENT_PERMISSION_REQUIRED, onParentPermissionRequired);
			
		}
		
		private function onIosPromoPurchaseFailed(e:BillingEvent):void
		{
			trace("onPromoPurchaseFailed: " + e.msg);
		}
		
		private function onIosPromoPurchaseSuccess(e:BillingEvent):void
		{
			trace("onPromoPurchase status: " + e.status);
			trace("onPromoPurchase msg: " + e.msg);
			
			if (e.purchase)
			{
				C.log("----------------");
				// we cannot determine the "billingType" on promo purchases!
				// It's your job to name your productId in a way so you will know this.
				C.log("$data.orderId = " + 				e.purchase.orderId);
				C.log("$data.developerPayload = " + 	e.purchase.developerPayload); // is always empty on promo purchases
				C.log("$data.productId = " +			e.purchase.productId);
				C.log("$data.purchaseState = " +		e.purchase.purchaseState);
				C.log("$data.purchaseTime = " +			e.purchase.purchaseTime);
				C.log("$data.purchaseToken = " +		e.purchase.purchaseToken);
				C.log("----------------");
				
				// If your promo purchase is not a consumable one, you surely expect to see it when
				// Billing.getPurchases(onGetPurchasesResult); is called, right?
				// to make sure you are seeing it, always clear cache when PROMO_PURCHASE_SUCCESS happens.
				
				// When you clear the cache, the ANE will try to get the purchase results fresh from app store.
				Billing.clearCache();
			}
		}
		
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
		
		private function onInitResult($status:int, $msg:String):void
		{
			/**
			 *	When developing, you may need to consume an already owned item. On the Android side, you may do as follow:
			 *	
			 *	Billing.forceConsume("productId", onResult);
			 *	function onResult($result:Boolean):void
			 *	{
			 *		if($result)
			 *		{
			 *			// your purchase has been consumed successfully
			 *		}
			 *		else
			 *		{
			 *			// something went wrong! You may try again.
			 *		}
			 *	}
			 * 
			 *	Unfortunately on the iOS side, you get "one shot" to buy your item because Apple remembers that your account has purchased that item.
			 *	If you need to test again, you need a different test account. There is no way to reset these purchases like how we can in Android.
			 */
			
			
			C.log("init was successful: " + Boolean($status));
			C.log("init msg = " + $msg);
			
			if (!Boolean($status))
			{
				C.log("\n There's been a problem initializing or supporting in-app-purchases. Are you sure you have setup your project correctly?");
				C.log("check the following probable causes:");
				
				C.log("\n General reasons:");
				C.log("\t 1) Check your internet connection");
				
				C.log("\n Android reasons:");
				C.log("\t 1) Have you uploaded your test .apk to your Google play console?");
				C.log("\t 2) Check your Android Key");
				C.log("\t 3) Your app must be in alpha, beta or release state on the Google console.");
				C.log("\t 4) Make sure your product IDs are matching the ones you entered in Google Play console?");
				C.log("\t 5) Sometimes it takes a few hours before Google can propagate your product IDs across all servers.");
				C.log("\t 6) Check this link: http://bfy.tw/3d26");
				
				C.log("\n iOS reasons:");
				C.log("\t 1) Check your product IDs based on what you setup in iTunes Connect console");
				C.log("\t 2) Have you completed the bank information and billing contracts with Apple yet?!");
				C.log("\t 3) Sometimes it takes a few hours before iTunes Connect can propagate your product IDs across all servers.");
				C.log("\t 4) read apple information here: https://developer.apple.com/in-app-purchase/");
				C.log("\t 5) Check this link: http://bfy.tw/3d1v");
				
				return;
			}
			else
			{
				C.log("Here's the list of available/online products which you can make purchases on them: \n");
				var availableProducts:Array = Billing.products;
				var currProduct:Product;
				for (var i:int = 0; i < availableProducts.length; i++) 
				{
					currProduct = availableProducts[i];
					C.log("\t productId = " + 	currProduct.productId);
					C.log("\t title = " + 		currProduct.title);
					C.log("\t description = " + currProduct.description);
					C.log("\t price = " + 		currProduct.price);
					C.log("\t currency = " + 	currProduct.currency);
					C.log("---------------------------------------");
				}
			}
			
			var btn2:MySprite = createBtn("getPurchases");
			btn2.addEventListener(MouseEvent.CLICK, getPurchases);
			_list.add(btn2);
			
			function getPurchases(e:MouseEvent):void
			{
				C.log("\n Checking what purchases this user has already made.");
				C.log("This method will return only permanet and subscription payments.");
				C.log("consumable purchases won't be saved on Google or Apple servers and you have to take care of them yourself if necessary based on your app logic.");
				C.log("If thinking like apple, you can consider this method as the \"restore\" functionalety on iOS in-app-purchases.");
				C.log("And it does of course do the same thing on Android. which means that if a user has purchase on device A, you will be able to return her purchases on device B with using this method.");
				C.log("\n Please wait for the list...");
				Billing.getPurchases(onGetPurchasesResult);
			}
			
			var btn3:MySprite = createBtn("purchase Consumable!");
			btn3.addEventListener(MouseEvent.CLICK, purchaseConsumable);
			_list.add(btn3);
			
			function purchaseConsumable(e:MouseEvent):void
			{
				C.log("Please wait...");
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					Billing.doPayment(BillingType.CONSUMABLE, "android.test.purchased", "Payload CONSUMABLE", onPurchaseResult);
//					Billing.doPayment(BillingType.PERMANENT, "android.test.purchased", "Payload PERMANENT", onPurchaseResult);
				}
				else
				{
					Billing.doPayment(BillingType.CONSUMABLE, "inappbilling_consumable_one", "Payload CONSUMABLE", onPurchaseResult);
				}
				
			}
			
			var btn5:MySprite = createBtn("Clear Cache");
			btn5.addEventListener(MouseEvent.CLICK, clearCache);
			_list.add(btn5);
			
			
			function clearCache(e:MouseEvent):void
			{
				Billing.clearCache();
				
				C.log("cache is now cleared!");
			}
			
			var btn6:MySprite = createBtn("get iOS Receipt");
			btn6.addEventListener(MouseEvent.CLICK, getiOSReceipt);
			_list.add(btn6);
			
			function getiOSReceipt(e:MouseEvent):void
			{
				trace("iOSReceipt: " + Billing.iOSReceipt);
			}
			
			onResize();
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
						C.log("----------------");
						C.log("purchaseData.orderId = " + 			purchaseData.orderId);
						C.log("purchaseData.productId = " +			purchaseData.productId);
						C.log("purchaseData.purchaseState = " +		purchaseData.purchaseState);
						C.log("purchaseData.purchaseTime = " +		purchaseData.purchaseTime);
						C.log("purchaseData.purchaseToken = " +		purchaseData.purchaseToken);
						
						if(OverrideAir.os == OverrideAir.ANDROID)
						{
							C.log("purchaseData.autoRenewing = " +		purchaseData.autoRenewing);
							C.log("purchaseData.signature = " +			purchaseData.signature);
						}
						C.log("----------------");
					}
				}
				else // if it's an empty Array, it means there are no purchase records for this user on the server.
				{
					C.log("\n There are no purchase records for this user on Google or Apple servers.");
				}
			}
			else
			{
				C.log("\n Error while trying to get the list of previously purchased records.")
			}
		}
		
		private function onPurchaseResult($status:int, $data:Purchase, $msg:String):void
		{
			C.log("\n purchase was successful? " + Boolean($status));
			
			if ($msg == Billing.ALREADY_OWNED_ITEM)
			{
				if(OverrideAir.os == OverrideAir.IOS)
				{
					C.log($msg);
				}
				else
				{
					C.log("Billing.ALREADY_OWNED_ITEM but for demo reasons we will force consume it!");
					Billing.forceConsume("android.test.purchased", onForceConsumeResult);
				}
			}
			else if ($msg == Billing.NOT_FOUND_ITEM)
			{
				C.log($msg);
			}
			else
			{
				C.log("purchase result message = " + $msg);
			}
			
			
			// to make sure your purchases are synced, it's always a good idea to clear local cache on a successful
			// purchase callback.
			Billing.clearCache();
			
			
			if ($data)
			{
				C.log("----------------");
				C.log("$data.billingType = " + 			$data.billingType);
				C.log("$data.orderId = " + 				$data.orderId);
				C.log("$data.developerPayload = " + 	$data.developerPayload);
				C.log("$data.productId = " +			$data.productId);
				C.log("$data.purchaseState = " +		$data.purchaseState);
				C.log("$data.purchaseTime = " +			$data.purchaseTime);
				C.log("$data.purchaseToken = " +		$data.purchaseToken);
				
				if(OverrideAir.os == OverrideAir.ANDROID)
				{
					C.log("$data.autoRenewing = " +		$data.autoRenewing);
					C.log("$data.signature = " +		$data.signature);
				}
				C.log("----------------");
			}
			
			function onForceConsumeResult($result:Boolean):void
			{
				if($result)
				{
					C.log("your purchase has been consumed successfully");
				}
				else
				{
					C.log("something went wrong! You may try again.");
				}
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function createBtn($str:String):MySprite
		{
			var sp:MySprite = new MySprite();
			sp.addEventListener(MouseEvent.MOUSE_OVER,  onOver);
			sp.addEventListener(MouseEvent.MOUSE_OUT,  onOut);
			sp.addEventListener(MouseEvent.CLICK,  onOut);
			sp.bgAlpha = 1;
			sp.bgColor = 0xDFE4FF;
			sp.drawBg();
			sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
			sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
			
			function onOver(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xFFDB48;
				sp.drawBg();
			}
			
			function onOut(e:MouseEvent):void
			{
				sp.bgAlpha = 1;
				sp.bgColor = 0xDFE4FF;
				sp.drawBg();
			}
			
			var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
			
			var txt:TextField = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			txt.mouseEnabled = false;
			txt.multiline = true;
			txt.wordWrap = true;
			txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
			txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
			txt.defaultTextFormat = format;
			txt.text = $str;
			
			txt.y = sp.height - txt.height >> 1;
			sp.addChild(txt);
			
			return sp;
		}
	}
	
}