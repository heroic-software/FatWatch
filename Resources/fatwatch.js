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
		var elt = document.getElementById(eltId);
		if (elt.type == "checkbox") {
			elt.checked = value;
		} else {
			elt.value = value;
		}
	}
}

var FWExportPresets = {
	"Everything":{
		"exportOrder":null,
		"exportDate":true,
		"exportDateName":"Date",
		"exportDateFormat":"y-MM-dd",
		"exportWeight":true,
		"exportWeightName":"Weight",
		"exportWeightFormat":"G",
		"exportTrendWeight":true,
		"exportFat":true,
		"exportFlag1":true,
		"exportFlag2":true,
		"exportFlag3":true,
		"exportFlag4":true,
		"exportNote":true
	},
	"Hacker's Diet Online":{
		"exportOrder":"date,weight,flag4,flag1,note",
		"exportDate":true,
		"exportDateName":"Date",
		"exportDateFormat":"y-MM-dd",
		"exportWeight":true,
		"exportWeightName":"Weight",
		"exportWeightFormat":"L",
		"exportTrendWeight":false,
		"exportFat":false,
		"exportFlag1":true,
		"exportFlag1Name":"Flag",
		"exportFlag2":false,
		"exportFlag3":false,
		"exportFlag4":false,
		"exportFlag4Name":"Rung",
		"exportNote":false,
		"exportNoteName":"Comment"
	},
	"TrueWeight":{
		"exportOrder":"date,weight",
		"exportDate":true,
		"exportDateName":"Date",
		"exportDateFormat":"y-MM-dd",
		"exportWeight":true,
		"exportWeightName":"Weight",
		"exportWeightFormat":"G",
		"exportTrendWeight":false,
		"exportFat":false,
		"exportFlag1":false,
		"exportFlag2":false,
		"exportFlag3":false,
		"exportFlag4":false,
		"exportNote":false
	}
};
