// out_png.jsx
function outputpng(){
	
	var doc = app.activeDocument;
	var pngOptions = new PNGSaveOptions()
	pngOptions.compression = 0; // 0 ~ 9
	pngOptions.interlaced = false; // 

	var pathFile = File.saveDialog('save png file', '*.png');
	if (pathFile){
		if (pathFile.exists){	// 如果文件存在提示一下
			var answer = confirm('存在相同文件是否保存?');
			if (answer){
				doc.saveAs(pathFile, pngOptions, true, Extension.LOWERCASE)
			}
		}else{
			doc.saveAs(pathFile, pngOptions, true, Extension.LOWERCASE)
		}
	}
}

outputpng();