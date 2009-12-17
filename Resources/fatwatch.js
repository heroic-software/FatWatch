function performTextSubstitution() {
	var title = 'FatWatch on ' + FatWatch['deviceName'];
	document.title = title;
	$("#bigtitle").text(title);
	$(".deviceModel").text(FatWatch['deviceModel']);
	$("#copyright").text(FatWatch['copyright']);
}

function configureTabs() {
	var defaultTab;

	if (document.location.hash) {
		defaultTab = '[href=' + document.location.hash + ']';
	} else {
		defaultTab = ':first';
	}
	
	var tabContainers = $("#tabs > div");
	$("a.tablink").click(function(event){
						 tabContainers.hide().filter(this.hash).show();
						 $("a.tablink")
						 .removeClass('selected')
						 .filter('[href=' + this.hash + ']')
						 .addClass('selected');
						 }).filter(defaultTab).click();
}

function updateSelectOptions(formats, eltId) {
	var selectElt = document.getElementById(eltId);
	while (selectElt.lastChild != null) {
		selectElt.removeChild(selectElt.lastChild);
	}
	for (i in formats) {
		var optionInfo = formats[i];
		var optionElt = document.createElement("option");
		optionElt.value = optionInfo['value'];
		optionElt.innerHTML = optionInfo['label'];
		selectElt.appendChild(optionElt);
	}
}

function updateFormValues(defaults) {
	for (eltId in defaults) {
		var value = defaults[eltId];
		if (value) {
			document.getElementById(eltId).value = value;
		} else {
			document.getElementById(eltId).checked = false;
		}
	}
}