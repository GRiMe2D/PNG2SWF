//	PNG2SWF - Making PNG sequence from SWF file
//	Copyright (C) 2025  Shakhzod Ikromov (aka GRiM2D)
//
//	This program is free software; you can redistribute it and/or
//	modify it under the terms of the GNU General Public License
//	as published by the Free Software Foundation; either version 2
//	of the License, or (at your option) any later version.
//
//			This program is distributed in the hope that it will be useful,
//			but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//			You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the Free Software
//	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
//	aabbcc.double@gmail.com


package {

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public final class Main extends Sprite {

		private const swfLoader:Loader = new Loader();
		private const controlGroup:Sprite = new Sprite();
		private const loadFileButton:Button = new Button("Load file");
		private const convertButton:Button = new Button("Convert");
		private const widthInput:TextInput = new TextInput();
		private const heightInput:TextInput = new TextInput();
		private const framesInput:TextInput = new TextInput();
		private const progressBar:ProgressBar = new ProgressBar();
		private var bytes:ByteArray;
		private const blurFilter:Array = [new BlurFilter(5, 5, 3)];

		public function Main() {
			initStage();
			initUI();
		}

		private function initStage():void {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
		}

		private function initUI():void {
			swfLoader.x = 10;
			swfLoader.y = 10;

			widthInput.label = "Width";
			widthInput.width = loadFileButton.width + 10 + convertButton.width;

			heightInput.label = "Height";
			heightInput.width = widthInput.width;
			heightInput.y = widthInput.height + 10;

			framesInput.label = "Frames";
			framesInput.width = widthInput.width;
			framesInput.y = widthInput.height + 10 + heightInput.height + 10;

			convertButton.y = widthInput.height + 10 + heightInput.height + 10 + framesInput.height + 10;
			convertButton.enabled = false;
			convertButton.addEventListener(MouseEvent.CLICK, convertButton_clickHandler);

			loadFileButton.x = convertButton.width + 10;
			loadFileButton.y = convertButton.y;
			loadFileButton.addEventListener(MouseEvent.CLICK, loadFileButton_clickHandler);

			progressBar.y = convertButton.y + convertButton.height + 10;
			progressBar.width = heightInput.width;
			progressBar.value = 0;

			controlGroup.addChild(widthInput);
			controlGroup.addChild(heightInput);
			controlGroup.addChild(framesInput);
			controlGroup.addChild(loadFileButton);
			controlGroup.addChild(convertButton);
			controlGroup.addChild(progressBar);

			this.addChild(swfLoader);
			this.addChild(controlGroup);
			this.stage.color = 0xEEEEEE;
			this.stage.addEventListener(Event.RESIZE, resizeHandler);
		}

		private function resizeHandler(event:Event):void {
			const rect:Rectangle = controlGroup.getBounds(this);
			controlGroup.x += this.stage.stageWidth - 10 - rect.right;
			controlGroup.y += this.stage.stageHeight - 10 - rect.bottom;

			swfLoaderContentFit()
		}

		private function swfLoaderContentFit():void {
			if (!swfLoader.content) return;
			const contentRect:Rectangle = new Rectangle(0, 0, swfLoader.content.width, swfLoader.content.height);
			const avaliableRect:Rectangle = new Rectangle(swfLoader.x, swfLoader.y, 100, 100);
			avaliableRect.width = this.stage.stageWidth - avaliableRect.x - 10 - controlGroup.width;
			avaliableRect.height = this.stage.stageHeight - avaliableRect.y - 10 - controlGroup.height;

			swfLoader.scaleX = avaliableRect.width / contentRect.width;
			swfLoader.scaleY = avaliableRect.height / contentRect.height;

			const minScale:Number = Math.min(swfLoader.scaleX, swfLoader.scaleY);
			swfLoader.scaleX = minScale;
			swfLoader.scaleY = minScale;
		}

		private function loadFileButton_clickHandler(event:MouseEvent):void {
			const fileRef:FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, fileRef_selectHandler);
			fileRef.browse([new FileFilter("SWF files", "*.swf")]);
		}

		private function fileRef_selectHandler(event:Event):void {
			const fileRef:FileReference = event.currentTarget as FileReference;
			fileRef.addEventListener(Event.COMPLETE, fileRef_completeHandler);
			fileRef.load();
		}

		private function fileRef_completeHandler(event:Event):void {
			const fileRef:FileReference = event.currentTarget as FileReference;
			fileRef.removeEventListener(Event.SELECT, fileRef_selectHandler);
			fileRef.removeEventListener(Event.COMPLETE, fileRef_completeHandler);

			bytes = fileRef.data;
			const context:LoaderContext = new LoaderContext(false);
			context.allowCodeImport = true;
			context.allowLoadBytesCodeExecution = true;

			swfLoader.unloadAndStop();
			swfLoader.loadBytes(bytes, context);
			swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);

			convertButton.enabled = true;
		}

		private function completeHandler(event:Event):void {
			swfLoaderContentFit();
		}

		private function convertButton_clickHandler(event:MouseEvent):void {
			widthInput.filters = blurFilter;
			widthInput.enabled = false;
			heightInput.filters = blurFilter;
			heightInput.enabled = false;
			framesInput.filters = blurFilter;
			framesInput.enabled = false;

			const width:Number = Number(widthInput.value);
			const height:Number = Number(heightInput.value);
			const frames:Number = Number(framesInput.value);

			if (width <= 0) {
				widthInput.filters = null;
				widthInput.enabled = true;
				return;
			}

			if (height <= 0) {
				heightInput.filters = null;
				heightInput.enabled = true;
				return;
			}

			if (frames <= 0) {
				framesInput.filters = null;
				framesInput.enabled = true;
				return;
			}

			widthInput.filters = null;
			heightInput.filters = null;
			framesInput.filters = null;
			convertButton.enabled = false;
			loadFileButton.enabled = false;

			this.renderedBitmaps.length = 0;

			const context:LoaderContext = new LoaderContext(false);
			context.allowCodeImport = true;
			context.allowLoadBytesCodeExecution = true;

			swfLoader.unloadAndStop();
			swfLoader.loadBytes(bytes, context);
			swfLoader.addEventListener(Event.EXIT_FRAME, exitFrameHandler);
		}

		private var renderedBitmaps:Vector.<BitmapData> = new <BitmapData>[];
		private function exitFrameHandler(event:Event):void {
			const width:Number = Number(widthInput.value);
			const height:Number = Number(heightInput.value);
			const frames:Number = Number(framesInput.value);
			const bitmapData:BitmapData = new BitmapData(width, height);
			bitmapData.draw(swfLoader.content);

			this.renderedBitmaps.insertAt(this.renderedBitmaps.length, bitmapData);
			progressBar.value = this.renderedBitmaps.length / frames;

			if (renderedBitmaps.length >= frames) {
				swfLoader.removeEventListener(Event.EXIT_FRAME, exitFrameHandler);
				saveData();
			}
		}

		private function saveData():void {
			const directory:File = new File();
			directory.addEventListener(Event.SELECT, directory_selectHandler);
			directory.browseForSave("Save PNG sequence");
		}

		private function directory_selectHandler(event:Event):void {
			const numCount:Number = Math.floor(Math.log(this.renderedBitmaps.length) / Math.log(10)) + 1;
			const baseFileName:File = event.currentTarget as File;

			var _bytes:ByteArray;
			var _data:BitmapData;
			for (var i:int = 0; i < this.renderedBitmaps.length; i++) {
				var fileName:String = i.toString();
				while (fileName.length < numCount) {
					fileName = "0" + fileName;
				}
				fileName += ".png";

				_data = this.renderedBitmaps[i];
				_bytes = _data.encode(_data.rect, new PNGEncoderOptions());

				const file:File = new File(baseFileName.nativePath + fileName);
				const fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(_bytes, 0, _bytes.length);
				fileStream.close();
			}

			widthInput.enabled = true;
			heightInput.enabled = true;
			framesInput.enabled = true;
			convertButton.enabled = true;
			loadFileButton.enabled = true;
		}
	}
}

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

final class Button extends SimpleButton {

	private var _label:String;
	public function get label():String {
		return this._label;
	}
	public function set label(newValue:String):void {
		this._label = newValue;
		this.validate();
	}


	public function Button(label:String = "") {
		super();
		this.label = label;
		this.validate();
	}

	private function validate():void {
		var sprite:Sprite = new Sprite();
		var bitmap:Bitmap = new Resource.RS_Button_UpState();
		var textField:TextField = this.getTextField();
		sprite.addChild(bitmap);
		sprite.addChild(textField);
		textField.x = (bitmap.width - textField.width) / 2;
		textField.y = (bitmap.height - 6 - textField.height) / 2;

		this.upState = sprite;
		this.hitTestState = sprite;
		this.overState = sprite;


		sprite = new Sprite();
		bitmap = new Resource.RS_Button_Pressed();
		textField = this.getTextField();
		sprite.addChild(bitmap);
		sprite.addChild(textField);
		textField.x = (bitmap.width - textField.width) / 2;
		textField.y = (bitmap.height - 6 - textField.height) / 2 + 6;

		this.downState = sprite;
	}

	private function getTextField():TextField {
		const textField:TextField = new TextField();
		textField.textColor = 0xFFFFFF;
		textField.selectable = false;
		textField.autoSize = TextFieldAutoSize.LEFT;
		textField.defaultTextFormat = new TextFormat("Menlo", 13);
		textField.text = this.label;
		return textField;
	}


	override public function set enabled(value:Boolean):void {
		if (value) {
			this.alpha = 1.0;
		} else {
			this.alpha = 0.8;
		}
		this.mouseEnabled = value;
		super.enabled = value;
	}
}

final class TextInput extends Sprite {
	private const background:Bitmap = new Resource.RS_TEXT_EDIT();
	private const labelField:TextField = new TextField();
	private const valueField:TextField = new TextField();
	public function TextInput() {
		background.scale9Grid = new Rectangle(7, 2, 286, 30);

		labelField.textColor = 0xFFFFFF;
		labelField.selectable = false;
		labelField.autoSize = TextFieldAutoSize.LEFT;
		labelField.defaultTextFormat = new TextFormat("Menlo", 13);

		valueField.textColor = 0x333333;
		valueField.type = TextFieldType.INPUT;
		valueField.border = false;
		valueField.borderColor = 0x333333;
		valueField.defaultTextFormat = new TextFormat("Menlo", 13);
		valueField.height = background.height - background.scale9Grid.top - background.height + background.scale9Grid.height - 7;
		valueField.width = background.width - background.scale9Grid.left - background.width + background.scale9Grid.width - 75;
		valueField.x = background.scale9Grid.left + 100 * background.scaleX;
		valueField.y = (background.height - 6 - valueField.height) / 2;
		valueField.restrict = "[0-9]";

		this.addChild(background);
		this.addChild(labelField);
		this.addChild(valueField);
	}

	public function get label():String {
		return labelField.text;
	}

	public function get enabled():Boolean {
		return valueField.mouseEnabled;
	}

	public function set enabled(value:Boolean):void {
		valueField.mouseEnabled = value;
		valueField.type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
	}

	public function set label(value:String):void {
		labelField.text = value;
		labelField.x = 10;
		labelField.y = (background.height - 6  - labelField.height) / 2;
	}

	public function get value():String {
		return valueField.text;
	}

	public function set value(value:String):void {
		valueField.text = value;
	}

	override public function set width(value:Number):void {
		background.width = value;
	}


	override public function get width():Number {
		return background.width;
	}

	override public function set height(value:Number):void {
		background.height = value;
	}

	override public function get height():Number {
		return background.height;
	}
}

final class ProgressBar extends Sprite {
	private const progress:Shape = new Shape();
	private const background:Bitmap = new Resource.RS_PROGRESS_BAR();
	private var _value:Number = 0;
	public function ProgressBar() {
		progress.graphics.beginFill(0xff4564);
		progress.graphics.drawRect(3, 3, background.width - 6, background.height - 6 - 6);
		progress.graphics.endFill();

		this.addChild(background);
		this.addChild(progress);

		this.scale9Grid = new Rectangle(7, 1, 138, 15);
	}

	public function set value(value:Number):void {
		value = Math.max(0, Math.min(1, value));
		this._value = value;
		progress.scaleX = value;
	}

	public function get value():Number {
		return this._value;
	}
}